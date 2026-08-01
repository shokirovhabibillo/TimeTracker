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
class MorphingNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Axis axis;

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

    return Container(
      margin: EdgeInsets.all(isHorizontal ? 12 : 16),
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 8 : 10,
        vertical: isHorizontal ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final count = items.length;
        final slotSize = isHorizontal
            ? (constraints.maxWidth - 16) / count
            : 56.0;

        final indicator = AnimatedAlign(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          alignment: isHorizontal
              ? Alignment(-1 + (2 / (count - 1)) * selectedIndex, 0)
              : Alignment(0, -1 + (2 / (count - 1)) * selectedIndex),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
          ),
        );

        final iconsList = List.generate(items.length, (i) {
          final selected = i == selectedIndex;
          final item = items[i];
          return Expanded(
            flex: isHorizontal ? 1 : 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(i),
              child: SizedBox(
                width: isHorizontal ? null : slotSize,
                height: isHorizontal ? 56 : slotSize,
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected ? scheme.onPrimary : scheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        });

        final content = isHorizontal
            ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: iconsList)
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: iconsList
                    .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: w))
                    .toList(),
              );

        return SizedBox(
          height: isHorizontal ? 56 : null,
          width: isHorizontal ? null : 56,
          child: Stack(alignment: Alignment.center, children: [indicator, content]),
        );
      }),
    );
  }
}
