import 'package:flutter/material.dart';

class Timeline extends StatelessWidget {
  final List<String> items;
  final Color? accentColor;
  final double? circleSize;
  final double? fontSize;

  const Timeline({
    super.key,
    required this.items,
    this.accentColor,
    this.circleSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.orange;
    final circleWidth = circleSize ?? 32.0;
    final textSize = fontSize ?? 15.0;

    return Column(
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length -1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              Column(
                children: [
                  // Step number circle
                  Container(
                    width: circleWidth,
                    height: circleWidth,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: circleWidth * 0.4,
                        )
                      )
                    ),
                  ),

                  // Connecting vertical line
                  if (!isLast) ... [
                    Expanded(
                      child: Container(
                        width: 2,
                        color: color.withOpacity(0.3),
                      )
                    )
                  ]
                ]
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: textSize,
                      height: 1.4,
                      color: Colors.black87,
                    )
                  )
                )
              )
            ]
          ),
        );
      }).toList(),
    );
  }
}