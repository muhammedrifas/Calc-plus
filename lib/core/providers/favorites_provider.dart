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

  // IMPORTANT: Ensure these string IDs exactly match the IDs used in your app's module registry
  static const _defaultFavorites = [
    'basic_math', 
    'unit_converter', 
    'loan_emi'
  ];

  FavoritesNotifier(this._prefs) : super(_loadInitialFavorites(_prefs));

  static List<String> _loadInitialFavorites(SharedPreferences prefs) {
    // If the key doesn't exist, it is a fresh install.
    if (!prefs.containsKey(_key)) {
      prefs.setStringList(_key, _defaultFavorites);
      return _defaultFavorites;
    }
    // Otherwise, load saved favorites (returns [] if the user manually unpinned them all)
    return prefs.getStringList(_key) ?? [];
  }

  void toggleFavorite(String moduleId) {
    if (state.contains(moduleId)) {
      state = state.where((id) => id != moduleId).toList();
    } else {
      state = [...state, moduleId];
    }
    _prefs.setStringList(_key, state);
  }
}