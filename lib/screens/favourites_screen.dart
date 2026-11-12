import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../widgets/dessert_card.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обране')),
      body: StoreConnector<AppState, AppState>(
        converter: (s) => s.state,
        builder: (context, state) {
          if (state.favourites.isEmpty) {
            return const Center(
              child: Text('Поки що нічого немає 💔\nНатисни ♥ на десерті',
                  textAlign: TextAlign.center),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: state.favourites.length,
            itemBuilder: (_, i) => DessertCard(dessert: state.favourites[i]),
          );
        },
      ),
    );
  }
}
