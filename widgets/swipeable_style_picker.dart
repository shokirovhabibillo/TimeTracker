import 'package:flutter/material.dart';

class SwipeableStylePicker extends StatefulWidget {
  final String label;
  final List<String> ids;
  final Map<String, String> displayLabels;
  final String value;
  final ValueChanged<String> onChanged;
  final Widget Function(String id) previewBuilder;

  const SwipeableStylePicker({
    super.key,
    required this.label,
    required this.ids,
    required this.displayLabels,
    required this.value,
    required this.onChanged,
    required this.previewBuilder,
  });

  @override
  State<SwipeableStylePicker> createState() => _SwipeableStylePickerState();
}

class _SwipeableStylePickerState extends State<SwipeableStylePicker> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.ids.indexOf(widget.value).clamp(0, widget.ids.length - 1);
    _controller = PageController(initialPage: _index, viewportFraction: 0.6);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.ids.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                widget.onChanged(widget.ids[i]);
              },
              itemBuilder: (context, i) {
                final id = widget.ids[i];
                final selected = i == _index;
                return AnimatedScale(
                  scale: selected ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 200),
                  child: Opacity(
                    opacity: selected ? 1.0 : 0.4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(fit: BoxFit.scaleDown, child: widget.previewBuilder(id)),
                          ),
                        ),
                        Text(widget.displayLabels[id] ?? id,
                            style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.ids.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
