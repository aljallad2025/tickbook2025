import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class WishlistButton extends StatelessWidget {
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomLeft;
  final double radiusBottomRight;
  final double iconHeight;

  const WishlistButton({
    super.key,
    required this.eventId,
    this.radiusTopLeft = 8,
    this.radiusTopRight = 8,
    this.radiusBottomLeft = 8,
    this.radiusBottomRight = 8,
    this.iconHeight = 20,
  });
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final isWishListed = context.watch<WishlistProvider>().isWishlisted(
      int.tryParse(eventId) ?? -1,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusTopLeft),
          bottomRight: Radius.circular(radiusBottomRight),
          topRight: Radius.circular(radiusTopRight),
          bottomLeft: Radius.circular(radiusBottomLeft),
        ),
        onTap: () async {
          final id = int.tryParse(eventId) ?? 0;
          final prov = context.read<WishlistProvider>();
          final wasWishlisted = prov.isWishlisted(id);
          await prov.toggleWishlist(eventId: id);
          if (!context.mounted) return;
          if (wasWishlisted) {
            final del = prov.deleteResultNotifier.value;
            if (del != null) {
              CustomSnackBar.show(
                iconBgColor: AppColors.snackError,
                context,
                del.message.tr,
              );
            }
          } else {
            final add = prov.addResultNotifier.value;
            if (add != null) {
              CustomSnackBar.show(
                iconBgColor: AppColors.snackSuccess,
                context,
                add.message.tr,
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isWishListed ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radiusTopLeft),
              bottomRight: Radius.circular(radiusBottomRight),
              topRight: Radius.circular(radiusTopRight),
              bottomLeft: Radius.circular(radiusBottomLeft),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isWishListed ? Colors.white : AppColors.primaryColor,
              width: 1,
            ),
          ),
          child: SvgPicture.asset(
            AssetsPath.bookmarkSvg,
            height: iconHeight,
            colorFilter: ColorFilter.mode(
              isWishListed ? Colors.white : AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
