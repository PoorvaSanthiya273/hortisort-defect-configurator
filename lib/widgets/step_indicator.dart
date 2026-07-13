import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final List<String> labels;
  final void Function(int)? onStepTap;

  const StepIndicator(
      {super.key,
      required this.current,
      required this.total,
      required this.labels,
      this.onStepTap});

  static const _icons = [
    Icons.settings,
    Icons.search,
    Icons.bar_chart,
    Icons.call_split,
    Icons.visibility,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final active = i == current;
            final done = i < current;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  Container(
                    width: 34,
                    height: 3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5),
                        color: done || active
                            ? AppTheme.greenHighlight
                            : AppTheme.darkGrey),
                  ),
                GestureDetector(
                  onTap: done ? () => onStepTap?.call(i) : null,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppTheme.greenHighlight
                            : Colors.transparent,
                        border: Border.all(
                            color: active
                                ? AppTheme.greenHighlight
                                : done
                                    ? AppTheme.greenHighlight
                                        .withValues(alpha: 0.5)
                                    : AppTheme.secondaryText,
                            width: done && !active ? 2.5 : (active ? 0 : 2)),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                    color: AppTheme.greenHighlight
                                        .withValues(alpha: 0.4),
                                    blurRadius: 14,
                                    spreadRadius: 2)
                              ]
                            : null,
                      ),
                      child: Center(
                          child: Icon(_icons[i],
                              size: 16,
                              color: active
                                  ? AppTheme.primaryText
                                  : done
                                      ? AppTheme.greenHighlight
                                          .withValues(alpha: 0.6)
                                      : AppTheme.secondaryText)),
                    ),
                    const SizedBox(height: 5),
                    Text(labels[i],
                        style: TextStyle(
                            color: active
                                ? AppTheme.greenHighlight
                                : done
                                    ? AppTheme.greenHighlight
                                        .withValues(alpha: 0.5)
                                    : AppTheme.secondaryText,
                            fontSize: 14,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
