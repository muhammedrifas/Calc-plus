import 'package:flutter/material.dart';
import '../core/registry/module_registry.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ModuleRegistry.groupedByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniCalc', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
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
                  children: modules.map((module) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: module.primaryColor.withOpacity(0.2),
                      child: Icon(module.icon, color: module.primaryColor),
                    ),
                    title: Text(module.name),
                    subtitle: Text(module.description),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => module.buildUI(context)),
                      );
                    },
                  )).toList(),
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