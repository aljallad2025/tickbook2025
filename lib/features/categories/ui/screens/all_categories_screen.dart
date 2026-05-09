import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:evento_app/features/categories/providers/categories_provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:evento_app/app/app_routes.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriesProvider()..ensureInitialized(),
      child: Consumer<CategoriesProvider>(
        builder: (context, prov, _) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'All Categories'),
            body: RefreshIndicator(
              backgroundColor: AppColors.primaryColor,
              color: Colors.white,
              onRefresh: () => context.read<CategoriesProvider>().refresh(),
              child: prov.loading && !prov.initialized
                  ? const _GridShimmer()
                  : prov.error != null
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            prov.error!,
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    )
                  : _CategoriesGrid(items: prov.items, loading: prov.loading),
            ),
          );
        },
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final List<CategoryModel> items;
  final bool loading;
  const _CategoriesGrid({required this.items, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) return const _GridShimmer();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final c = items[index];
        return _CategoryTile(category: c);
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed(
            AppRoutes.bottomNav,
            arguments: {
              'index': 1,
              'categoryId': category.id,
              'categoryName': category.name,
              'categorySlug': category.slug,
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: SafeNetworkImage(
                  category.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
