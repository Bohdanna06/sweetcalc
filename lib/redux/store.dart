import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'app_state.dart';
import 'reducers.dart';

Store<AppState> createStore() => Store<AppState>(
      appReducer,
      initialState: AppState.initial(),
      middleware: [thunkMiddleware],
    );
