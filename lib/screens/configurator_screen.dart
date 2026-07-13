import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/configurator_provider.dart';
import '../providers/program_config_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/login_dropdown.dart';
import '../widgets/program_config_step.dart';
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
    'Program',
    'Defects',
    'Histogram',
    'Outlet',
    'Review'
  ];
  static const _totalSteps = 5;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfiguratorProvider, ProgramConfigProvider>(
      builder: (context, configP, programP, _) {
        return Scaffold(
          backgroundColor: AppTheme.mainBg,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final narrow = w < 768;
                return Column(
                  children: [
                    _topBar(context, configP, programP, narrow),
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

  Widget _topBar(BuildContext context, ConfiguratorProvider p,
      ProgramConfigProvider pp, bool narrow) {
    final h = narrow ? 68.0 : 84.0;
    final logoH = narrow ? 40.0 : 52.0;
    final gap = narrow ? 6.0 : 12.0;
    return Container(
      height: h,
      padding: EdgeInsets.only(
          left: narrow ? 12 : 28, right: narrow ? 8 : 16, top: 6, bottom: 4),
      decoration: const BoxDecoration(color: AppTheme.headerBg),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SvgPicture.asset('assets/logo.svg', height: logoH),
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
          _navBtn('< Back', _currentStep > 0, () {
            if (_currentStep == 1) p.markAllDefectsSaved();
            setState(() => _currentStep--);
          }),
        if (!narrow) const SizedBox(width: 6),
        _navBtn(
            narrow
                ? (_currentStep == 4 ? 'S' : '>')
                : (_currentStep == 4 ? 'Save' : 'Next >'),
            _nextEnabled(p, pp), () {
          if (_currentStep == 4) {
            final pp =
                Provider.of<ProgramConfigProvider>(context, listen: false);
            final cp =
                Provider.of<ConfiguratorProvider>(context, listen: false);
            cp.setProgramName(pp.programName);
            cp.setProduceName(pp.produceName);
            cp.saveConfiguration(
                programName: pp.programName, produceName: pp.produceName);
          } else {
            if (_currentStep == 0 || _currentStep == 1) {
              final cp =
                  Provider.of<ConfiguratorProvider>(context, listen: false);
              cp.setProgramName(pp.programName);
              cp.setProduceName(pp.produceName);
            }
            if (_currentStep == 0) {
              Provider.of<ConfiguratorProvider>(context, listen: false)
                  .loadVisionFeatures(pp.visionFeatures);
            }
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

  bool _nextEnabled(ConfiguratorProvider p, ProgramConfigProvider pp) {
    if (_currentStep == 0) return pp.canProceed;
    if (_currentStep == 1) return p.canProceedFromDefects;
    if (_currentStep == 2) return p.canProceedFromHistogram;
    return true;
  }

  Widget _stepContent() {
    switch (_currentStep) {
      case 0:
        return const ProgramConfigStep();
      case 1:
        return const DefectsStep();
      case 2:
        return const HistogramStep();
      case 3:
        return const OutletsStep();
      case 4:
        return const PreviewStep();
      default:
        return const ProgramConfigStep();
    }
  }
}
