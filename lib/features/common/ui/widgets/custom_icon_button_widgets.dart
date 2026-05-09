import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButtonWidget extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final double height;
  final double width;
  final double? iconHeight;
  final double? iconWidth;
  final bool showCircle;
  final bool showRectangle;
  final bool flipHorizontally;

  const CustomIconButtonWidget({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.height = 38.0,
    this.width = 38.0,
    this.iconHeight,
    this.iconWidth,
    this.showCircle = false,
    this.showRectangle = true,
    this.flipHorizontally = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCircle = showCircle && !showRectangle;
    final borderRadius = isCircle ? null : BorderRadius.circular(6);

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: borderRadius,
        ),
        alignment: Alignment.center,
        child: flipHorizontally
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
                child: SvgPicture.asset(
                  assetPath,
                  height: iconHeight,
                  width: iconWidth,
                ),
              )
            : SvgPicture.asset(assetPath, height: iconHeight, width: iconWidth),
      ),
    );
  }
}
