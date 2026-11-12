import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/app_state.dart';
import 'redux/store.dart';
import 'screens/main_shell.dart';

void main() => runApp(SweetCalcApp(store: createStore()));

class SweetCalcApp extends StatelessWidget {
  final Store<AppState> store;
  const SweetCalcApp({super.key, required this.store});

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: b,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, bool>(
        converter: (s) => s.state.darkMode,
        builder: (context, dark) => MaterialApp(
          title: 'SweetCalc',
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const MainShell(),
        ),
      ),
    );
  }
}
