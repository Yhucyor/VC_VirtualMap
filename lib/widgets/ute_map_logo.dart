import 'package:flutter/material.dart';

class UteMapLogo extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const UteMapLogo({
    super.key, 
    this.size = 120, 
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainColor = primaryColor ?? colorScheme.primary;
    final accentColor = secondaryColor ?? colorScheme.secondary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Map folds
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size * 0.25,
                height: size * 0.65,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Container(
                width: size * 0.25,
                height: size * 0.75,
                color: mainColor.withValues(alpha: 0.25),
              ),
              Container(
                width: size * 0.25,
                height: size * 0.65,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          // Map Pin overlapping
          Positioned(
            top: size * 0.05,
            child: Icon(
              Icons.location_on,
              size: size * 0.6,
              color: mainColor,
            ),
          ),
          // UTE Text inside the pin
          Positioned(
            top: size * 0.16,
            child: Text(
              'UTE',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.16,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // A little route dotted line at the bottom
          Positioned(
            bottom: size * 0.18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: size * 0.035, backgroundColor: accentColor),
                SizedBox(width: size * 0.05),
                Container(
                  width: size * 0.12,
                  height: size * 0.02,
                  color: accentColor.withValues(alpha: 0.6),
                ),
                SizedBox(width: size * 0.05),
                Icon(Icons.flag, size: size * 0.16, color: accentColor),
              ],
            ),
          )
        ],
      ),
    );
  }
}
