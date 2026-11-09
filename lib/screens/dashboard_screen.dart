import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_calc/core/registry/module_registry.dart';
import 'package:omni_calc/core/providers/favorites_provider.dart';
import 'package:omni_calc/core/theme/app_theme_extension.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.omniTheme;
    final categories = ModuleRegistry.groupedByCategory;
    final favoriteIds = ref.watch(favoritesProvider);

    final favoriteModules = ModuleRegistry.allModules
        .where((m) => favoriteIds.contains(m.id))
        .toList();

    final isSearching = _searchQuery.trim().isNotEmpty;
    final searchResults = isSearching ? ModuleRegistry.search(_searchQuery.trim()) : [];

    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(
        title: const Text('OmniCalc', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search calculators...',
                  leading: Icon(Icons.search, color: theme.textMuted),
                  trailing: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: theme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(theme.surface),
                  textStyle: WidgetStateProperty.all(TextStyle(color: theme.textPrimary)),
                  hintStyle: WidgetStateProperty.all(TextStyle(color: theme.textMuted)),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
            ),

            if (isSearching) ...[
              // Search Results View
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Search Results (${searchResults.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ),
              if (searchResults.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text(
                        'No calculators match "$_searchQuery"',
                        style: TextStyle(color: theme.textMuted, fontSize: 15),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = searchResults[index];
                      final isFav = favoriteIds.contains(module.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: module.primaryColor.withOpacity(0.18),
                          child: Icon(module.icon, color: module.primaryColor, size: 20),
                        ),
                        title: Text(
                          module.name,
                          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          module.description,
                          style: TextStyle(color: theme.textMuted, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isFav ? theme.chartSecondary : theme.textMuted,
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
                    },
                    childCount: searchResults.length,
                  ),
                ),
            ] else ...[
              // Favorites Grid (Compact size)
              if (favoriteModules.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Text(
                      'Favorites',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.85, // Slimmer profile
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final module = favoriteModules[index];
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => module.buildUI(context)),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  module.primaryColor.withOpacity(0.7),
                                  module.primaryColor.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: module.primaryColor.withOpacity(0.35)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(module.icon, size: 22, color: Colors.white),
                                  Text(
                                    module.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
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
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],

              // All Categories List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Text(
                    'All Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories.keys.elementAt(index);
                    final modules = categories[category]!;

                    if (modules.isEmpty) return const SizedBox.shrink();

                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        iconColor: theme.secondary,
                        collapsedIconColor: theme.textMuted,
                        title: Text(
                          category.displayName,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        children: modules.map((module) {
                          final isFav = favoriteIds.contains(module.id);
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: module.primaryColor.withOpacity(0.18),
                              child: Icon(module.icon, color: module.primaryColor, size: 18),
                            ),
                            title: Text(
                              module.name,
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              module.description,
                              style: TextStyle(color: theme.textMuted, fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isFav ? theme.chartSecondary : theme.textMuted,
                                size: 20,
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
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ],

            // Bottom safe inset spacing to prevent system navigation bleed-through
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}