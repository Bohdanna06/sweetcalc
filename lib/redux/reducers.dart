import 'actions.dart';
import 'app_state.dart';

AppState appReducer(AppState s, dynamic a) {
  if (a is DessertsLoading) return s.copyWith(loading: true, clearError: true);
  if (a is DessertsLoaded) return s.copyWith(desserts: a.items, loading: false);
  if (a is DessertsFailed) return s.copyWith(loading: false, error: a.message);

  if (a is DetailLoading) {
    return s.copyWith(detailLoading: true, clearDetail: true, clearDetailError: true);
  }
  if (a is DetailLoaded) return s.copyWith(detail: a.detail, detailLoading: false);
  if (a is DetailFailed) return s.copyWith(detailLoading: false, detailError: a.message);

  if (a is ToggleFavourite) {
    final exists = s.favourites.any((d) => d.id == a.dessert.id);
    return s.copyWith(
      favourites: exists
          ? s.favourites.where((d) => d.id != a.dessert.id).toList()
          : [...s.favourites, a.dessert],
    );
  }

  if (a is AddToShopping) {
    final have = s.shopping.map((e) => e.name.toLowerCase()).toSet();
    final added = a.names
        .where((n) => !have.contains(n.toLowerCase()))
        .map((n) => ShoppingItem(n));
    return s.copyWith(shopping: [...s.shopping, ...added]);
  }
  if (a is ToggleShoppingItem) {
    return s.copyWith(
      shopping: s.shopping.map((e) => e.name == a.name ? e.toggled() : e).toList(),
    );
  }
  if (a is RemoveShoppingItem) {
    return s.copyWith(shopping: s.shopping.where((e) => e.name != a.name).toList());
  }
  if (a is ClearShopping) return s.copyWith(shopping: []);

  if (a is SetPrice) return s.copyWith(prices: {...s.prices, a.key: a.price});

  if (a is SetUserName) return s.copyWith(userName: a.name);
  if (a is ToggleDarkMode) return s.copyWith(darkMode: !s.darkMode);

  return s;
}
