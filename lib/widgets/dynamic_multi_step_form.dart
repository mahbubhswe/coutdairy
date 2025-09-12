import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Represents a single step in [DynamicMultiStepForm].
class FormStep {
  /// Title displayed in the stepper header.
  final Widget title;

  /// Content of the step.
  final Widget content;

  const FormStep({required this.title, required this.content});
}

/// A lightweight replacement for the `dynamic_multi_step_form` package.
///
/// Displays a simple [Stepper] with next/back navigation and calls
/// [onSubmit] when the last step is completed.
class DynamicMultiStepForm extends StatefulWidget {
  const DynamicMultiStepForm({
    super.key,
    required this.steps,
    required this.onSubmit,
    this.isLoading = false,
    this.stepperType = StepperType.horizontal,
    this.controlsInBottom = false,
    this.stepIconColor,
    this.headerColor,
    this.controlsPadding = const EdgeInsets.all(16),
    this.tightHorizontal = false,
    this.completedColor,
  });

  /// Ordered list of form steps.
  final List<FormStep> steps;

  /// Callback invoked when the final step is submitted.
  final VoidCallback onSubmit;

  /// Whether a submit operation is in progress.
  final bool isLoading;

  /// Orientation of the [Stepper]. Defaults to [StepperType.horizontal].
  final StepperType stepperType;

  /// When true, renders Back/Next/Submit controls fixed at the bottom
  /// instead of inline within the Stepper.
  final bool controlsInBottom;

  /// Custom color for the step index icons and connectors.
  final Color? stepIconColor;

  /// Background color for the custom header when [tightHorizontal] is true.
  final Color? headerColor;

  /// Padding for the fixed bottom controls area when [controlsInBottom] is true.
  final EdgeInsetsGeometry controlsPadding;

  /// When true, uses a custom compact step header/content without
  /// the default Stepper's horizontal padding.
  final bool tightHorizontal;

  /// Color used for completed step indicators and connectors in
  /// tight mode. Defaults to teal when null.
  final Color? completedColor;

  @override
  State<DynamicMultiStepForm> createState() => _DynamicMultiStepFormState();
}

class _DynamicMultiStepFormState extends State<DynamicMultiStepForm> {
  int _currentStep = 0;

  void _next() {
    if (widget.isLoading) return;
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onSubmit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentStep == widget.steps.length - 1;

    if (widget.tightHorizontal) {
      final cs = Theme.of(context).colorScheme;
      final Color active = widget.stepIconColor ?? cs.primary;
      final Color inactive = cs.outlineVariant;
      final Color completed = widget.completedColor ?? Colors.teal;

      Widget header = Container(
        color: widget.headerColor,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.steps.asMap().entries.map((entry) {
              final int idx = entry.key;
              final bool isActive = idx <= _currentStep;
              final bool isCurrent = idx == _currentStep;
              final bool isCompleted = idx < _currentStep;
              return GestureDetector(
                onTap: () => setState(() => _currentStep = idx),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(
                    children: [
                      // Step indicator
                      Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        // Fill the current step with the active color for strong contrast
                        color: isCurrent ? active : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? completed
                              : (isActive ? active : inactive),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w500,
                          // Ensure the current number contrasts against its background
                          color: isCurrent
                              ? ((active.computeLuminance() < 0.5)
                                  ? Colors.white
                                  : Colors.black)
                              : (isCompleted
                                  ? completed
                                  : (isActive ? active : inactive)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 13,
                        color: isActive ? cs.onSurface : cs.onSurfaceVariant,
                        fontWeight: isCurrent
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: entry.value.title,
                    ),
                    // connector
                    if (idx != widget.steps.length - 1) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 2,
                        color: (idx < _currentStep) ? completed : inactive,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );

      Widget content = widget.steps[_currentStep].content;

      Widget inlineControls = Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _back,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('পেছনে'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _next,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: widget.isLoading && isLast
                ? const CupertinoActivityIndicator()
                : Text(isLast ? 'জমা দিন' : 'পরবর্তী'),
          ),
        ],
      );

      if (!widget.controlsInBottom) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: content,
              ),
            ),
            Padding(padding: const EdgeInsets.all(8.0), child: inlineControls),
          ],
        );
      }

      return Column(
        children: [
          // Header without side padding
          header,
          // Content fills remaining space
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: content,
            ),
          ),
          // Bottom controls
          SafeArea(
            top: false,
            child: Padding(
              padding: widget.controlsPadding,
              child: inlineControls,
            ),
          ),
        ],
      );
    }

    Widget stepper = Stepper(
      type: widget.stepperType,
      currentStep: _currentStep,
      onStepTapped: (i) => setState(() => _currentStep = i),
      onStepContinue: _next,
      onStepCancel: _back,
      controlsBuilder: widget.controlsInBottom
          ? (context, details) => const SizedBox.shrink()
          : (context, details) {
              return Row(
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _back,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                      ),
                      child: const Text('Back'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.isLoading ? null : _next,
                    child: widget.isLoading && isLast
                        ? const CupertinoActivityIndicator()
                        : Text(isLast ? 'Submit' : 'Next'),
                  ),
                ],
              );
            },
      steps: widget.steps
          .asMap()
          .entries
          .map(
            (entry) => Step(
              title: entry.value.title,
              content: entry.value.content,
              isActive: entry.key <= _currentStep,
            ),
          )
          .toList(),
    );

    if (widget.stepIconColor != null) {
      stepper = Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: widget.stepIconColor),
        ),
        child: stepper,
      );
    }

    if (!widget.controlsInBottom) return stepper;

    return Column(
      children: [
        Expanded(child: stepper),
        SafeArea(
          top: false,
          child: Padding(
            padding: widget.controlsPadding,
            child: Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _back,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _next,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: widget.isLoading && isLast
                      ? const CupertinoActivityIndicator()
                      : Text(isLast ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
