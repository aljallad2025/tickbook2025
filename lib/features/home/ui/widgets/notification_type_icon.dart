import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationTypeIcon extends StatelessWidget {
  final String type;
  const NotificationTypeIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final iconMap = {
      // "Order": AssetsPath.orderHistorySvg,
      // "Booking": AssetsPath.reservationSvg,
      // "Payment": AssetsPath.walletSvg,
      "Schedule": AssetsPath.clockSvg,
    };

    final asset = iconMap.entries
        .firstWhere(
          (e) => type.contains(e.key),
          orElse: () => MapEntry('', AssetsPath.notificationSvg),
        )
        .value;

    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
    );
  }
}

