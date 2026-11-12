import '../models/meal.dart';
import '../utils/measure_parser.dart';

class ShoppingItem {
  final String name;
  final bool done;
  const ShoppingItem(this.name, {this.done = false});
  ShoppingItem toggled() => ShoppingItem(name, done: !done);
}

class AppState {
  final List<Dessert> desserts;
  final bool loading;
  final String? error;

  final MealDetail? detail;
  final bool detailLoading;
  final String? detailError;

  final List<Dessert> favourites;
  final List<ShoppingItem> shopping;

  /// Ціни інгредієнтів за одиницю (кг / л / шт). Ключ: назва малими літерами.
  final Map<String, UnitPrice> prices;

  final String userName;
  final bool darkMode;

  const AppState({
    required this.desserts,
    required this.loading,
    required this.error,
    required this.detail,
    required this.detailLoading,
    required this.detailError,
    required this.favourites,
    required this.shopping,
    required this.prices,
    required this.userName,
    required this.darkMode,
  });

  factory AppState.initial() => const AppState(
        desserts: [],
        loading: false,
        error: null,
        detail: null,
        detailLoading: false,
        detailError: null,
        favourites: [],
        shopping: [],
        prices: {},
        userName: 'Кондитер',
        darkMode: false,
      );

  AppState copyWith({
    List<Dessert>? desserts,
    bool? loading,
    String? error,
    bool clearError = false,
    MealDetail? detail,
    bool clearDetail = false,
    bool? detailLoading,
    String? detailError,
    bool clearDetailError = false,
    List<Dessert>? favourites,
    List<ShoppingItem>? shopping,
    Map<String, UnitPrice>? prices,
    String? userName,
    bool? darkMode,
  }) =>
      AppState(
        desserts: desserts ?? this.desserts,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        detail: clearDetail ? null : (detail ?? this.detail),
        detailLoading: detailLoading ?? this.detailLoading,
        detailError: clearDetailError ? null : (detailError ?? this.detailError),
        favourites: favourites ?? this.favourites,
        shopping: shopping ?? this.shopping,
        prices: prices ?? this.prices,
        userName: userName ?? this.userName,
        darkMode: darkMode ?? this.darkMode,
      );
}