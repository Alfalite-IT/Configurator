import 'package:flutter/material.dart';

class ResultCard extends StatefulWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final String? tooltipMessage;
  final bool isWide;

  const ResultCard({
    super.key,
    required this.label,
    required this.value,
    required this.isHighlight,
    required this.tooltipMessage,
    required this.isWide,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _isZoomed = false;

  @override
  Widget build(BuildContext context) {
    // A very subtle, almost imperceptible scale for the card.
    final double cardScale = widget.isWide && _isZoomed ? 1.03 : 1.0;
    // A very large font size for the text, which will be scaled down by FittedBox.
    final double targetFontSize = 50.0;

    final double elevation = widget.isWide && _isZoomed ? 24.0 : 4.0;

    final valueStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: widget.isHighlight ? Colors.black : Theme.of(context).primaryColor,
    );

    return MouseRegion(
      onEnter: (_) {
        if (widget.isWide) setState(() => _isZoomed = true);
      },
      onExit: (_) {
        if (widget.isWide) setState(() => _isZoomed = false);
      },
      child: GestureDetector(
        onTap: () {
          if (widget.isWide) setState(() => _isZoomed = !_isZoomed);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: cardScale,
          child: Card(
            elevation: elevation,
            color: widget.isHighlight ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            widget.value,
                            // When zoomed, the font size becomes huge, but FittedBox scales it down.
                            style: valueStyle.copyWith(fontSize: _isZoomed ? targetFontSize : null),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isHighlight ? Colors.black87 : Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (widget.tooltipMessage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Tooltip(
                      message: widget.tooltipMessage!,
                      triggerMode: TooltipTriggerMode.tap,
                      child: Icon(
                        Icons.help_outline,
                        size: 16,
                        color: (widget.isHighlight ? Colors.black : Colors.white).withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 