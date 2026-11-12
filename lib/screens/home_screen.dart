import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../widgets/dessert_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Мережевий виклик при першому відкритті
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false).dispatch(fetchDesserts());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('🍰 SweetCalc')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Пошук десерту (англ.), напр. cake',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    store.dispatch(fetchDesserts());
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onSubmitted: (q) => store.dispatch(fetchDesserts(q)),
            ),
          ),
          Expanded(
            child: StoreConnector<AppState, AppState>(
              converter: (s) => s.state,
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.error!),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => store.dispatch(fetchDesserts()),
                          child: const Text('Повторити'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.desserts.isEmpty) {
                  return const Center(child: Text('Нічого не знайдено'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: state.desserts.length,
                  itemBuilder: (_, i) => DessertCard(dessert: state.desserts[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
