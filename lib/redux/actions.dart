import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import '../utils/measure_parser.dart';
import 'app_state.dart';

// ---------- Прості дії ----------
class DessertsLoading {}

class DessertsLoaded {
  final List<Dessert> items;
  DessertsLoaded(this.items);
}

class DessertsFailed {
  final String message;
  DessertsFailed(this.message);
}

class DetailLoading {}

class DetailLoaded {
  final MealDetail? detail;
  DetailLoaded(this.detail);
}

class DetailFailed {
  final String message;
  DetailFailed(this.message);
}

class ToggleFavourite {
  final Dessert dessert;
  ToggleFavourite(this.dessert);
}

class AddToShopping {
  final List<String> names;
  AddToShopping(this.names);
}

class ToggleShoppingItem {
  final String name;
  ToggleShoppingItem(this.name);
}

class RemoveShoppingItem {
  final String name;
  RemoveShoppingItem(this.name);
}

class ClearShopping {}

class SetPrice {
  final String key;
  final UnitPrice price;
  SetPrice(this.key, this.price);
}

class SetUserName {
  final String name;
  SetUserName(this.name);
}

class ToggleDarkMode {}

// ---------- Асинхронні дії (thunk) ----------
final _api = MealApi();

ThunkAction<AppState> fetchDesserts([String query = '']) {
  return (Store<AppState> store) async {
    store.dispatch(DessertsLoading());
    try {
      final items = query.trim().isEmpty
          ? await _api.fetchDesserts()
          : await _api.searchDesserts(query.trim());
      store.dispatch(DessertsLoaded(items));
    } catch (e) {
      store.dispatch(DessertsFailed('Не вдалося завантажити десерти. Перевір інтернет.'));
    }
  };
}

ThunkAction<AppState> fetchDetail(String id) {
  return (Store<AppState> store) async {
    store.dispatch(DetailLoading());
    try {
      store.dispatch(DetailLoaded(await _api.fetchDetail(id)));
    } catch (e) {
      store.dispatch(DetailFailed('Не вдалося завантажити рецепт.'));
    }
  };
}