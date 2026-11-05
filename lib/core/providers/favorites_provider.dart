import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A provider to hold the SharedPreferences instance synchronously
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// The main provider the UI will listen to
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return FavoritesNotifier(prefs);
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const _key = 'pinned_favorites';

  FavoritesNotifier(this._prefs) : super(_prefs.getStringList(_key) ?? []);

  void toggleFavorite(String moduleId) {
    if (state.contains(moduleId)) {
      state = state.where((id) => id != moduleId).toList();
    } else {
      state = [...state, moduleId];
    }
    _prefs.setStringList(_key, state);
  }
}