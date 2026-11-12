import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../models/meal.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../utils/measure_parser.dart';

/// Калькулятор собівартості: ціна за кг / л / шт -> вартість під рецепт.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int _servings = 8;
  double _margin = 40;

  /// Кількості, введені вручну (коли рецепт не вдалося розпізнати).
  final Map<String, double> _manual = {};

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double _toDouble(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор собівартості')),
      body: StoreConnector<AppState, AppState>(
        converter: (s) => s.state,
        builder: (context, state) {
          final d = state.detail;
          final favIds = state.favourites.map((f) => f.id).toList();
          final selected = (d != null && favIds.contains(d.id)) ? d.id : null;

          var total = 0.0;
          var unpriced = 0;
          var unresolved = 0;
          var approx = false;
          final rows = <Widget>[];

          if (d != null) {
            for (final ing in d.ingredients) {
              final nameKey = ing.name.toLowerCase();
              final manualKey = '${d.id}|$nameKey';
              final parsed = parseMeasure(ing.measure);
              final up = state.prices[nameKey];
              final manual = _manual[manualKey];
              final hasPrice = up != null && up.price > 0;

              CostResult? auto;
              CostResult? res;
              if (hasPrice) {
                auto = computeCost(parsed, up);
                res = manual != null
                    ? computeCost(parsed, up, manualAmount: manual)
                    : auto;
                if (res.cost == null) {
                  unresolved++;
                } else {
                  total += res.cost!;
                  if (res.approximate) approx = true;
                }
              } else {
                unpriced++;
              }

              rows.add(_ingredientCard(
                store: store,
                ing: ing,
                nameKey: nameKey,
                manualKey: manualKey,
                parsed: parsed,
                up: up,
                hasPrice: hasPrice,
                auto: auto,
                res: res,
                manual: manual,
              ));
            }
          }

          final perServing = _servings > 0 ? total / _servings : 0.0;
          final recommended = perServing * (1 + _margin / 100);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (favIds.isEmpty)
                const Text('Додай рецепт в «Обране», щоб порахувати його собівартість.')
              else
                DropdownButton<String>(
                  isExpanded: true,
                  value: selected,
                  hint: const Text('Оберіть рецепт з обраного'),
                  items: state.favourites
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                      .toList(),
                  onChanged: (id) {
                    if (id != null) store.dispatch(fetchDetail(id));
                  },
                ),
              if (state.detailLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (d != null && !state.detailLoading) ...[
                const SizedBox(height: 12),
                Text(d.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                const Text(
                    'Введи ціну за кг / л / шт. Ціни запам\'ятовуються для всіх рецептів.'),
                const SizedBox(height: 8),
                ...rows,
                const Divider(height: 32),
                Row(
                  children: [
                    const Text('Порцій:'),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          _servings > 1 ? () => setState(() => _servings--) : null,
                    ),
                    Text('$_servings', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _servings++),
                    ),
                  ],
                ),
                Text('Націнка: ${_margin.round()}%'),
                Slider(
                  value: _margin,
                  min: 0,
                  max: 200,
                  divisions: 40,
                  label: '${_margin.round()}%',
                  onChanged: (v) => setState(() => _margin = v),
                ),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Загальна собівартість: ${total.toStringAsFixed(2)} грн'),
                        Text('Собівартість порції: ${perServing.toStringAsFixed(2)} грн'),
                        const SizedBox(height: 8),
                        Text(
                          'Рекомендована ціна порції: ${recommended.toStringAsFixed(2)} грн',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (unpriced > 0) ...[
                          const SizedBox(height: 8),
                          Text('⚠️ Без ціни: $unpriced інгр. (не враховано)'),
                        ],
                        if (unresolved > 0) ...[
                          const SizedBox(height: 4),
                          Text('⚠️ Не пораховано: $unresolved інгр. (введи кількість вручну)'),
                        ],
                        if (approx) ...[
                          const SizedBox(height: 4),
                          const Text(
                              'ℹ️ Частину вартості пораховано приблизно (склянки/ложки переведені у вагу).'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _ingredientCard({
    required Store<AppState> store,
    required Ingredient ing,
    required String nameKey,
    required String manualKey,
    required ParsedMeasure parsed,
    required UnitPrice? up,
    required bool hasPrice,
    required CostResult? auto,
    required CostResult? res,
    required double? manual,
  }) {
    final unit = up?.unit ?? defaultUnitFor(parsed);

    Widget resultLine;
    if (!hasPrice) {
      resultLine = const Text('Введи ціну', style: TextStyle(color: Colors.grey));
    } else if (res!.cost != null) {
      resultLine = Text(
        '${res.approximate ? '≈ ' : ''}${res.cost!.toStringAsFixed(2)} грн',
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      resultLine = const Text('Не вдалося порахувати',
          style: TextStyle(color: Colors.orange));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('За рецептом: ${ing.measure.isEmpty ? '—' : ing.measure}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('$manualKey|price'),
                    initialValue: up == null || up.price == 0 ? '' : _fmt(up.price),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Ціна, грн',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => store
                        .dispatch(SetPrice(nameKey, UnitPrice(_toDouble(v), unit))),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<PriceUnit>(
                  value: unit,
                  items: PriceUnit.values
                      .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                      .toList(),
                  onChanged: (u) {
                    if (u != null) {
                      store.dispatch(SetPrice(nameKey, UnitPrice(up?.price ?? 0, u)));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            resultLine,
            if (hasPrice && auto != null && auto.cost == null) ...[
              const SizedBox(height: 8),
              TextFormField(
                key: ValueKey('$manualKey|manual'),
                initialValue: manual == null ? '' : _fmt(manual),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Скільки потрібно (у ${unit.short})',
                  suffixText: unit.short,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() {
                  final n = _toDouble(v);
                  if (n > 0) {
                    _manual[manualKey] = n;
                  } else {
                    _manual.remove(manualKey);
                  }
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}