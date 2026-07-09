import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/configurator_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/login_dropdown.dart';
import '../widgets/defects_step.dart';
import '../widgets/histogram_step.dart';
import '../widgets/outlets_step.dart';
import '../widgets/preview_step.dart';

class ConfiguratorScreen extends StatefulWidget {
  const ConfiguratorScreen({super.key});

  @override
  State<ConfiguratorScreen> createState() => _ConfiguratorScreenState();
}

class _ConfiguratorScreenState extends State<ConfiguratorScreen> {
  int _currentStep = 0;

  static const _labels = [
    'Defects',
    'Histogram',
    'Outlet Assignment',
    'Review & Save'
  ];
  static const _totalSteps = 4;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(
      builder: (context, p, _) {
        return Scaffold(
          backgroundColor: AppTheme.mainBg,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final narrow = w < 768;
                return Column(
                  children: [
                    _topBar(context, p, narrow),
                    Expanded(child: _stepContent()),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, ConfiguratorProvider p, bool narrow) {
    final h = narrow ? 60.0 : 76.0;
    final logoH = narrow ? 28.0 : 36.0;
    final gap = narrow ? 6.0 : 20.0;
    return Container(
      height: h,
      padding: EdgeInsets.only(
          left: narrow ? 12 : 28, right: narrow ? 8 : 16, top: 6, bottom: 4),
      decoration: const BoxDecoration(color: AppTheme.headerBg),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SvgPicture.asset('assets/logo.svg', height: logoH),
        if (!narrow) const SizedBox(width: 6),
        if (!narrow)
          const Text('HORTISORT',
              style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3)),
        SizedBox(width: gap),
        Expanded(
            child: StepIndicator(
                current: _currentStep,
                total: _totalSteps,
                labels: _labels,
                onStepTap: (step) {
                  if (step <= _currentStep) setState(() => _currentStep = step);
                })),
        const SizedBox(width: 8),
        if (!narrow)
          _navBtn(
              '< Back', _currentStep > 0, () => setState(() => _currentStep--)),
        if (!narrow) const SizedBox(width: 6),
        _navBtn(
            narrow
                ? (_currentStep == 3 ? 'S' : '>')
                : (_currentStep == 3 ? 'Save' : 'Next >'),
            _nextEnabled(p), () {
          if (_currentStep == 3) {
            Provider.of<ConfiguratorProvider>(context, listen: false)
                .saveConfiguration();
          } else {
            setState(() => _currentStep++);
          }
        }),
        const SizedBox(width: 8),
        const LoginDropdown(),
      ]),
    );
  }

  Widget _navBtn(String label, bool enabled, VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: TextButton(
          onPressed: enabled ? onTap : null,
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              backgroundColor: enabled
                  ? AppTheme.darkGrey
                  : AppTheme.darkGrey.withValues(alpha: 0.5),
              foregroundColor:
                  enabled ? AppTheme.primaryText : AppTheme.secondaryText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                      color: enabled
                          ? AppTheme.greenHighlight
                          : AppTheme.secondaryText))),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
    );
  }

  bool _nextEnabled(ConfiguratorProvider p) {
    if (_currentStep == 0) return p.canProceedFromDefects;
    return true;
  }

  Widget _stepContent() {
    switch (_currentStep) {
      case 0:
        return const DefectsStep();
      case 1:
        return const HistogramStep();
      case 2:
        return const OutletsStep();
      case 3:
        return const PreviewStep();
      default:
        return const DefectsStep();
    }
  }
}
