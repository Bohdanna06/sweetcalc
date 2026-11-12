import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: StoreConnector<AppState, AppState>(
        converter: (s) => s.state,
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.userName,
              decoration: const InputDecoration(
                labelText: "Ім'я",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => store.dispatch(SetUserName(v)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Темна тема'),
              value: state.darkMode,
              onChanged: (_) => store.dispatch(ToggleDarkMode()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Рецептів в обраному'),
              trailing: Text('${state.favourites.length}'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text('Позицій у списку покупок'),
              trailing: Text('${state.shopping.length}'),
            ),
          ],
        ),
      ),
    );
  }
}
