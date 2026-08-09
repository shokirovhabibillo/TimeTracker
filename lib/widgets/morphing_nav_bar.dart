import 'package:flutter/material.dart';

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

    final barLength = slotSize * count;

    return Container(
      margin: EdgeInsets.all(isHorizontal ? 12 : 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.32),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
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
  }
}
