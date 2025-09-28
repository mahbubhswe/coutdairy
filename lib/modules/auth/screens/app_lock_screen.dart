import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../services/pin_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key, this.setupMode = false});

  final bool setupMode; // true = create/confirm PIN, false = enter to unlock

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();
  final _pinFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();
  bool _confirmPhase = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    _pinFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (widget.setupMode) {
      if (!_confirmPhase) {
        if (_controller.text.length < 4) {
          setState(() => _error = 'কমপক্ষে ৪টি সংখ্যা দিন');
          _pinFocusNode.requestFocus();
          return;
        }
        setState(() {
          _confirmPhase = true;
          _error = null;
        });
        Future.delayed(const Duration(milliseconds: 180), () {
          if (!mounted) return;
          _confirmController.clear();
          _confirmFocusNode.requestFocus();
        });
        return;
      } else {
        if (_controller.text != _confirmController.text) {
          setState(() => _error = 'দুটি পিন মেলেনি');
          _confirmController.clear();
          Future.delayed(const Duration(milliseconds: 120), () {
            if (mounted) {
              _confirmFocusNode.requestFocus();
            }
          });
          return;
        }
        setState(() => _error = null);
        final ok = await PinLockService.setPin(_controller.text);
        if (!mounted) return;
        if (ok) {
          Get.back(result: true);
        } else {
          setState(() => _error = 'পিন সেভ করা যায়নি');
        }
      }
    } else {
      if (_controller.text.isEmpty) {
        setState(() => _error = 'পিন লিখুন');
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            _pinFocusNode.requestFocus();
          }
        });
        return;
      }
      setState(() => _error = null);
      final ok = await PinLockService.verifyPin(_controller.text);
      if (!mounted) return;
      if (ok) {
        Get.back(result: true);
      } else {
        setState(() => _error = 'ভুল পিন');
        _controller.clear();
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            _pinFocusNode.requestFocus();
          }
        });
      }
    }
  }

  void _resetSetupFlow() {
    setState(() {
      _confirmPhase = false;
      _error = null;
      _confirmController.clear();
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _pinFocusNode.requestFocus();
    });
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
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required VoidCallback onSubmitted,
    bool autoFocus = false,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autoFocus,
      keyboardType: TextInputType.number,
      obscureText: true,
      obscuringCharacter: '●',
      maxLength: 12,
      style: theme.textTheme.titleMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'শুধু সংখ্যা লিখুন',
        counterText: '',
        filled: true,
        fillColor: enabled
            ? colors.surfaceVariant.withOpacity(0.5)
            : colors.surfaceVariant.withOpacity(0.25),
        prefixIcon: Icon(icon, color: colors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.35)),
        ),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instruction = widget.setupMode
        ? (_confirmPhase
              ? 'নতুন পিনটি নিশ্চিত করুন'
              : '৪ বা ততোধিক ডিজিটের পিন দিন')
        : 'আপনার পিন লিখুন';

    return Scaffold(
       extendBodyBehindAppBar: true,
      backgroundColor: colors.surface,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primaryContainer.withOpacity(0.75), colors.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 12,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
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
                        controller: _controller,
                        focusNode: _pinFocusNode,
                        label: widget.setupMode ? 'নতুন পিন' : 'পিন',
                        icon: Icons.lock_outline,
                        autoFocus: !_confirmPhase,
                        enabled: !widget.setupMode || !_confirmPhase,
                        onSubmitted: _onSubmit,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: widget.setupMode && _confirmPhase
                            ? Column(
                                key: const ValueKey('confirm-field'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildPinField(
                                    controller: _confirmController,
                                    focusNode: _confirmFocusNode,
                                    label: 'পিন নিশ্চিত করুন',
                                    icon: Icons.verified_user_outlined,
                                    autoFocus: true,
                                    onSubmitted: _onSubmit,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _resetSetupFlow,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('পিন আবার লিখুন'),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('empty-confirm'),
                              ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _onSubmit,
                        icon: Icon(
                          widget.setupMode
                              ? (_confirmPhase
                                    ? Icons.check_circle_outline
                                    : Icons.arrow_forward_rounded)
                              : Icons.lock_open_rounded,
                        ),
                        label: Text(
                          widget.setupMode
                              ? (_confirmPhase ? 'পিন সেভ করুন' : 'পরবর্তী ধাপ')
                              : 'আনলক করুন',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
          ),
        ),
      ),
    );
  }
}
