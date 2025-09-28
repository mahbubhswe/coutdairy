import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/pin_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key, this.setupMode = false});

  final bool setupMode; // true = create/confirm PIN, false = enter to unlock

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pinInput = '';
  String _confirmInput = '';
  bool _confirmPhase = false;
  String? _error;
  bool _isProcessing = false;

  void _resetSetupFlow() {
    setState(() {
      _confirmPhase = false;
      _error = null;
      _confirmInput = '';
      _pinInput = '';
    });
  }

  void _onDigitPressed(String digit) {
    if (_isProcessing) return;

    setState(() {
      if (widget.setupMode && _confirmPhase) {
        if (_confirmInput.length < 4) {
          _confirmInput += digit;
        }
      } else {
        if (_pinInput.length < 4) {
          _pinInput += digit;
        }
      }
      _error = null;
    });

    final currentLength = widget.setupMode && _confirmPhase
        ? _confirmInput.length
        : _pinInput.length;

    if (currentLength == 4) {
      if (widget.setupMode) {
        if (_confirmPhase) {
          _completeSetup();
        } else {
          _beginConfirmPhase();
        }
      } else {
        _verifyExistingPin();
      }
    }
  }

  void _onBackspace() {
    if (_isProcessing) return;

    setState(() {
      _error = null;
      if (widget.setupMode && _confirmPhase) {
        if (_confirmInput.isNotEmpty) {
          _confirmInput =
              _confirmInput.substring(0, _confirmInput.length - 1);
        } else {
          _confirmPhase = false;
          if (_pinInput.isNotEmpty) {
            _pinInput = _pinInput.substring(0, _pinInput.length - 1);
          }
        }
      } else {
        if (_pinInput.isNotEmpty) {
          _pinInput = _pinInput.substring(0, _pinInput.length - 1);
        }
      }
    });
  }

  void _beginConfirmPhase() {
    setState(() {
      _confirmPhase = true;
      _confirmInput = '';
      _error = null;
    });
  }

  Future<void> _completeSetup() async {
    if (_confirmInput != _pinInput) {
      setState(() {
        _error = 'দুটি পিন মেলেনি';
        _confirmInput = '';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final ok = await PinLockService.setPin(_pinInput);
    if (!mounted) return;

    if (ok) {
      Get.back(result: true);
    } else {
      setState(() {
        _error = 'পিন সেভ করা যায়নি';
        _isProcessing = false;
      });
    }
  }

  Future<void> _verifyExistingPin() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final ok = await PinLockService.verifyPin(_pinInput);
    if (!mounted) return;

    if (ok) {
      Get.back(result: true);
    } else {
      setState(() {
        _error = 'ভুল পিন';
        _pinInput = '';
        _isProcessing = false;
      });
    }
  }

  Widget _buildStepPill({
    required String label,
    required IconData icon,
    required bool active,
    required bool complete,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final Color background;
    final Color foreground;
    final Color borderColor;

    if (complete) {
      background = colors.primary;
      foreground = colors.onPrimary;
      borderColor = colors.primary;
    } else if (active) {
      background = colors.primaryContainer.withOpacity(0.55);
      foreground = colors.onPrimaryContainer;
      borderColor = colors.primary;
    } else {
      background = colors.surfaceVariant.withOpacity(0.7);
      foreground =
          theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
          colors.onSurfaceVariant;
      borderColor = colors.outline.withOpacity(0.3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: active || complete ? 1.4 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinField({
    required String label,
    required IconData icon,
    required String value,
    required bool active,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: active ? colors.primary : colors.outline),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final filled = index < value.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 54,
              width: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: active
                    ? colors.primaryContainer.withOpacity(0.45)
                    : colors.surfaceVariant.withOpacity(0.4),
                border: Border.all(
                  color: active
                      ? colors.primary
                      : colors.outline.withOpacity(0.5),
                  width: active ? 1.8 : 1.2,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: filled
                    ? Text(
                        '●',
                        key: ValueKey('filled-$index'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                          fontSize: 28,
                        ),
                      )
                    : Text(
                        '–',
                        key: ValueKey('empty-$index'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.outline.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildKeyButton({
    String? digit,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isDisabled = onTap == null;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Material(
          color: isDisabled
              ? colors.surfaceVariant.withOpacity(0.2)
              : colors.surfaceVariant.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isDisabled ? null : onTap,
            child: SizedBox(
              height: 70,
              child: Center(
                child: digit != null
                    ? Text(
                        digit,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : icon != null
                        ? Icon(
                            icon,
                            size: 28,
                            color: colors.primary,
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            children: row
                .map(
                  (digit) => _buildKeyButton(
                    digit: digit,
                    onTap: () => _onDigitPressed(digit),
                  ),
                )
                .toList(),
          ),
        Row(
          children: [
            _buildKeyButton(onTap: null),
            _buildKeyButton(
              digit: '0',
              onTap: () => _onDigitPressed('0'),
            ),
            _buildKeyButton(
              icon: Icons.backspace_rounded,
              onTap: () => _onBackspace(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instruction = widget.setupMode
        ? (_confirmPhase
            ? 'নতুন পিনটি পুনরায় লিখুন'
            : 'চার সংখ্যার একটি নতুন পিন বাছাই করুন')
        : 'চার ডিজিটের পিন লিখুন';

    return Scaffold(
      backgroundColor: colors.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primaryContainer.withOpacity(0.75), colors.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colors.primary.withOpacity(0.95),
                          colors.secondary.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      widget.setupMode
                          ? Icons.lock_reset_rounded
                          : Icons.lock_open_rounded,
                      size: 36,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.setupMode ? 'নিরাপদ পিন সেট করুন' : 'স্বাগতম!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(
                      0.75,
                    ),
                  ),
                ),
                if (widget.setupMode) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStepPill(
                          label: 'ধাপ ১',
                          icon: _confirmPhase
                              ? Icons.check_circle_outline
                              : Icons.looks_one_outlined,
                          active: !_confirmPhase,
                          complete: _confirmPhase,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStepPill(
                          label: 'ধাপ ২',
                          icon: Icons.looks_two_outlined,
                          active: _confirmPhase,
                          complete: false,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _error == null
                      ? const SizedBox.shrink(key: ValueKey('no-error'))
                      : Container(
                          key: const ValueKey('error'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.error.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: colors.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                _buildPinField(
                  label: widget.setupMode ? 'নতুন পিন' : 'পিন',
                  icon: Icons.lock_outline,
                  value: _pinInput,
                  active: !widget.setupMode || !_confirmPhase,
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: widget.setupMode && _confirmPhase
                      ? Column(
                          key: const ValueKey('confirm-field'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPinField(
                              label: 'পিন নিশ্চিত করুন',
                              icon: Icons.verified_user_outlined,
                              value: _confirmInput,
                              active: true,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('empty-confirm'),
                        ),
                ),
                if (widget.setupMode && _confirmPhase) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _resetSetupFlow,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('পিন আবার লিখুন'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 20),
                _buildKeypad(),
                const SizedBox(height: 12),
                if (_isProcessing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: CircularProgressIndicator(strokeWidth: 2.6),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'ব্যক্তিগত নিরাপত্তা নিশ্চিত করতে পিন কাউকে জানাবেন না।',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(
                      0.7,
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
