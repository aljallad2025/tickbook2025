import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/home/providers/nav_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            final nav = context.read<NavProvider>();
            final eventsProv = context.read<EventsProvider>();
            nav.setIndex(1);
            final isActive =
                (eventsProv.categoryId == category.id) ||
                ((eventsProv.categoryName ?? '').toLowerCase() ==
                    category.name.toLowerCase());
            if (isActive) {
              // Toggle off: restore full events (keeping other filters)
              eventsProv.clearCategoryFilter();
              return;
            }
            if (!eventsProv.initialized) {
              eventsProv.ensureInitialized(perPage: 15).then((_) {
                eventsProv.setCategoryFilter(
                  id: category.id,
                  name: category.name,
                  slug: category.slug,
                );
              });
            } else {
              eventsProv.setCategoryFilter(
                id: category.id,
                name: category.name,
                slug: category.slug,
              );
            }
          },
          child: Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 64,
                height: 64,
                child: _CategoryImageWithShimmer(url: category.image),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          category.name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CategoryImageWithShimmer extends StatefulWidget {
  final String url;
  const _CategoryImageWithShimmer({required this.url});

  @override
  State<_CategoryImageWithShimmer> createState() =>
      _CategoryImageWithShimmerState();
}

class _CategoryImageWithShimmerState extends State<_CategoryImageWithShimmer> {
  final bool _loaded = false;
  final bool _error = false;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: border,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_loaded && !_error)
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.grey.shade300),
            ),
          SafeNetworkImage(
            widget.url,
            fit: BoxFit.cover,
            placeholder: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.grey.shade300),
            ),
            errorWidget: Container(
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(Icons.category, size: 28, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
