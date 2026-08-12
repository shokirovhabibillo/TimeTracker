import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const NavItem({required this.icon, required this.selectedIcon, required this.label});
}

/// A navigation bar where the selected item's icon sits inside a colored
/// circle that animates ("morphs") to the newly selected position.
/// Renders as a horizontal pill (bottom bar) or vertical pill (side rail)
/// depending on [axis] — the caller picks based on device orientation.
///
/// Both the indicator circle and the icons are positioned from the same
/// slot-center calculation (slot index -> pixel center), so they always
/// line up exactly regardless of item count.
///
/// When the user has selected a "glass"/"liquid_glass" button style in
/// Settings, the bar renders as a dark frosted-glass pill (blurred,
/// translucent, with a soft top highlight) instead of the plain solid
/// pill — inspired by Telegram Plus's bottom bar look.
class MorphingNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Axis axis;
  static const double indicatorSize = 48;
  static const double slotSize = 56;

  const MorphingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHorizontal = axis == Axis.horizontal;
    final count = items.length;
    final buttonStyle = context.watch<SettingsProvider>().settings.buttonStyle;
    final isGlass = buttonStyle == 'glass' || buttonStyle == 'liquid_glass';
    final isLiquid = buttonStyle == 'liquid_glass';
    final barLength = slotSize * count;

    final navContent = Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: isHorizontal ? barLength : slotSize,
        height: isHorizontal ? slotSize : barLength,
        child: Stack(
          children: [
            // Indicator circle — centered in the selected slot.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              left: isHorizontal ? selectedIndex * slotSize + (slotSize - indicatorSize) / 2 : (slotSize - indicatorSize) / 2,
              top: isHorizontal ? (slotSize - indicatorSize) / 2 : selectedIndex * slotSize + (slotSize - indicatorSize) / 2,
              width: indicatorSize,
              height: indicatorSize,
              child: DecoratedBox(
                decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
              ),
            ),
            // Icons — each centered in its own slot, same slot math as the indicator.
            ...List.generate(count, (i) {
              final selected = i == selectedIndex;
              final item = items[i];
              return Positioned(
                left: isHorizontal ? i * slotSize : 0,
                top: isHorizontal ? 0 : i * slotSize,
                width: slotSize,
                height: slotSize,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => onSelected(i),
                    child: Center(
                      child: Icon(
                        selected ? item.selectedIcon : item.icon,
                        color: selected ? scheme.onPrimary : scheme.onSurface.withOpacity(0.6),
                        shadows: isGlass
                            ? null
                            : [
                                Shadow(color: Colors.black.withOpacity(0.55), blurRadius: 6),
                                Shadow(color: Colors.white.withOpacity(0.35), blurRadius: 3),
                              ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );

    // Dark, blurred, softly-lit pill for glass modes (a la Telegram Plus);
    // the flat translucent surface for the normal style.
    final box = Stack(
      fit: StackFit.loose,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: isGlass
                ? Colors.black.withOpacity(isLiquid ? 0.3 : 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: isGlass ? Border.all(color: Colors.white.withOpacity(isLiquid ? 0.22 : 0.14), width: 0.7) : null,
          ),
          child: navContent,
        ),
        if (isGlass)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: isGlass
          ? BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: box)
          : box,
    );

    return Container(
      margin: EdgeInsets.all(isHorizontal ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (isLiquid)
            BoxShadow(color: scheme.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))
          else if (isGlass)
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: clipped,
    );
  }
}
