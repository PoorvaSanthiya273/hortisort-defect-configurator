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
            child: Column(
              children: [
                _topBar(context, p),
                Expanded(child: _stepContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, ConfiguratorProvider p) {
    return Container(
      height: 76,
      padding: const EdgeInsets.only(left: 28, right: 16, top: 6, bottom: 4),
      decoration: const BoxDecoration(
        color: AppTheme.headerBg,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SvgPicture.asset('assets/logo.svg', height: 36),
        const SizedBox(width: 6),
        const Text('HORTISORT',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 3)),
        const SizedBox(width: 20),
        Expanded(
            child: StepIndicator(
                current: _currentStep,
                total: _totalSteps,
                labels: _labels,
                onStepTap: (step) {
                  if (step <= _currentStep) {
                    setState(() => _currentStep = step);
                  }
                })),
        const SizedBox(width: 14),
        _navBtn('< Back', _currentStep > 0, () {
          setState(() => _currentStep--);
        }),
        const SizedBox(width: 10),
        _navBtn(_currentStep == 3 ? 'Save' : 'Next >', _nextEnabled(p), () {
          if (_currentStep == 3) {
            Provider.of<ConfiguratorProvider>(context, listen: false)
                .saveConfiguration();
          } else {
            setState(() => _currentStep++);
          }
        }),
        const SizedBox(width: 14),
        const LoginDropdown(),
      ]),
    );
  }

  Widget _bottomBar(ConfiguratorProvider p) {
    return Container(
      height: 48,
      color: AppTheme.orangeBar,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        const Text('Program: Defect Config',
            style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
                color: AppTheme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _navBtn(String label, bool enabled, VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: TextButton(
          onPressed: enabled ? onTap : null,
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
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
