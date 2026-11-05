import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/registry/module_registry.dart';
import 'package:omni_calc/core/providers/favorites_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ModuleRegistry.groupedByCategory;
    final favoriteIds = ref.watch(favoritesProvider);
    
    // Get the actual module objects for the pinned IDs
    final favoriteModules = ModuleRegistry.allModules
        .where((m) => favoriteIds.contains(m.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniCalc', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBar(
                hintText: 'Search calculators...',
                leading: const Icon(Icons.search),
                elevation: WidgetStateProperty.all(1),
              ),
            ),
          ),
          
          // Favorites Grid (Only shows if items are pinned)
          if (favoriteModules.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final module = favoriteModules[index];
                    return InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => module.buildUI(context))),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [module.primaryColor.withOpacity(0.8), module.primaryColor.withOpacity(0.4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(module.icon, size: 32, color: Colors.white),
                              const Spacer(),
                              Text(module.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: favoriteModules.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],

          // All Categories List
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('All Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories.keys.elementAt(index);
                final modules = categories[category]!;
                
                if (modules.isEmpty) return const SizedBox.shrink();

                return ExpansionTile(
                  title: Text(category.displayName),
                  children: modules.map((module) {
                    final isFav = favoriteIds.contains(module.id);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: module.primaryColor.withOpacity(0.2),
                        child: Icon(module.icon, color: module.primaryColor),
                      ),
                      title: Text(module.name),
                      subtitle: Text(module.description),
                      trailing: IconButton(
                        icon: Icon(
                          isFav ? Icons.star : Icons.star_border, 
                          color: isFav ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(module.id),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => module.buildUI(context)),
                        );
                      },
                    );
                  }).toList(),
                );
              },
              childCount: categories.length,
            ),
          ),
        ],
      ),
    );
  }
}