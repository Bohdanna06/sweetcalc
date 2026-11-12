/// Одиниці, у яких користувач вводить ціну.
enum PriceUnit { kg, l, piece }

extension PriceUnitX on PriceUnit {
  String get label => switch (this) {
        PriceUnit.kg => 'за кг',
        PriceUnit.l => 'за л',
        PriceUnit.piece => 'за шт',
      };

  String get short => switch (this) {
        PriceUnit.kg => 'кг',
        PriceUnit.l => 'л',
        PriceUnit.piece => 'шт',
      };
}

/// Ціна інгредієнта за одиницю (наприклад, 45 грн за кг).
class UnitPrice {
  final double price;
  final PriceUnit unit;
  const UnitPrice(this.price, this.unit);
}

enum Dimension { mass, volume, count, unknown }

/// Розпізнана кількість: маса в кг, об'єм у л, або штуки.
class ParsedMeasure {
  final double amount;
  final Dimension dim;
  const ParsedMeasure(this.amount, this.dim);
  static const unknown = ParsedMeasure(0, Dimension.unknown);
}

const _massUnits = <String, double>{
  'g': 0.001, 'gr': 0.001, 'gram': 0.001, 'grams': 0.001,
  'kg': 1, 'kilo': 1, 'kilos': 1, 'kilogram': 1, 'kilograms': 1,
  'oz': 0.02835, 'ounce': 0.02835, 'ounces': 0.02835,
  'lb': 0.4536, 'lbs': 0.4536, 'pound': 0.4536, 'pounds': 0.4536,
};

const _volumeUnits = <String, double>{
  'ml': 0.001, 'millilitre': 0.001, 'millilitres': 0.001,
  'milliliter': 0.001, 'milliliters': 0.001,
  'cl': 0.01, 'dl': 0.1,
  'l': 1, 'litre': 1, 'litres': 1, 'liter': 1, 'liters': 1,
  'tsp': 0.005, 'teaspoon': 0.005, 'teaspoons': 0.005,
  'tbsp': 0.015, 'tblsp': 0.015, 'tablespoon': 0.015, 'tablespoons': 0.015,
  'cup': 0.24, 'cups': 0.24,
  'pint': 0.473, 'pints': 0.473,
};

double? _parseNumber(String text) {
  final t = text.trim().replaceAll(',', '.');
  final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(t);
  if (mixed != null) {
    final den = int.parse(mixed[3]!);
    if (den == 0) return null;
    return int.parse(mixed[1]!) + int.parse(mixed[2]!) / den;
  }
  final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(t);
  if (frac != null) {
    final den = int.parse(frac[2]!);
    if (den == 0) return null;
    return int.parse(frac[1]!) / den;
  }
  return double.tryParse(t);
}

/// Розбирає текст кількості з рецепта: "200g", "1 1/2 cups", "3 large"...
ParsedMeasure parseMeasure(String raw) {
  var s = raw
      .toLowerCase()
      .replaceAll('½', ' 1/2')
      .replaceAll('¼', ' 1/4')
      .replaceAll('¾', ' 3/4')
      .trim();
  if (s.isEmpty) return ParsedMeasure.unknown;

  final m = RegExp(r'^\s*(\d+\s+\d+/\d+|\d+/\d+|\d+(?:[.,]\d+)?)\s*(.*)$')
      .firstMatch(s);
  if (m == null) return ParsedMeasure.unknown; // "pinch", "to taste"...

  final number = _parseNumber(m[1]!);
  if (number == null) return ParsedMeasure.unknown;

  // діапазон "2-3 tbsp" беремо перше число
  var rest = (m[2] ?? '')
      .trim()
      .replaceFirst(RegExp(r'^[-–]\s*\d+([.,]\d+)?\s*'), '');
  final unit = RegExp(r'^([a-z]+)').firstMatch(rest)?.group(1) ?? '';

  if (_massUnits.containsKey(unit)) {
    return ParsedMeasure(number * _massUnits[unit]!, Dimension.mass);
  }
  if (_volumeUnits.containsKey(unit)) {
    return ParsedMeasure(number * _volumeUnits[unit]!, Dimension.volume);
  }
  // "3 large", "2", "1 tin", "2 cloves" — вважаємо штуками
  return ParsedMeasure(number, Dimension.count);
}

/// Яку одиницю ціни запропонувати за замовчуванням.
PriceUnit defaultUnitFor(ParsedMeasure m) => switch (m.dim) {
      Dimension.mass => PriceUnit.kg,
      Dimension.volume => PriceUnit.l,
      _ => PriceUnit.piece,
    };

class CostResult {
  final double? cost; // null, якщо порахувати не вдалося
  final bool approximate; // true, якщо переводили вагу <-> об'єм (1 л ≈ 1 кг)
  const CostResult(this.cost, {this.approximate = false});
}

/// Рахує вартість інгредієнта.
/// [manualAmount] — кількість, яку користувач ввів вручну в одиницях ціни.
CostResult computeCost(ParsedMeasure m, UnitPrice p, {double? manualAmount}) {
  if (manualAmount != null) return CostResult(manualAmount * p.price);

  if (p.unit == PriceUnit.kg) {
    if (m.dim == Dimension.mass) return CostResult(m.amount * p.price);
    if (m.dim == Dimension.volume) {
      return CostResult(m.amount * p.price, approximate: true);
    }
  } else if (p.unit == PriceUnit.l) {
    if (m.dim == Dimension.volume) return CostResult(m.amount * p.price);
    if (m.dim == Dimension.mass) {
      return CostResult(m.amount * p.price, approximate: true);
    }
  } else if (p.unit == PriceUnit.piece) {
    if (m.dim == Dimension.count) return CostResult(m.amount * p.price);
  }
  return const CostResult(null);
}