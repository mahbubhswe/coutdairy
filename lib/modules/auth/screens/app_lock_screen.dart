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
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();
  bool _confirmPhase = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (widget.setupMode) {
      if (!_confirmPhase) {
        if (_controller.text.length < 4) {
          setState(() => _error = 'কমপক্ষে ৪টি সংখ্যা দিন');
          return;
        }
        setState(() {
          _confirmPhase = true;
          _error = null;
        });
        return;
      } else {
        if (_controller.text != _confirmController.text) {
          setState(() => _error = 'দুটি পিন মেলেনি');
          return;
        }
        final ok = await PinLockService.setPin(_controller.text);
        if (!mounted) return;
        if (ok) {
          Get.back(result: true);
        } else {
          setState(() => _error = 'পিন সেভ করা যায়নি');
        }
      }
    } else {
      final ok = await PinLockService.verifyPin(_controller.text);
      if (!mounted) return;
      if (ok) {
        Get.back(result: true);
      } else {
        setState(() => _error = 'ভুল পিন');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.setupMode ? 'অ্যাপ পিন সেট করুন' : 'অ্যাপ আনলক করুন'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              widget.setupMode
                  ? (_confirmPhase ? 'নতুন পিনটি নিশ্চিত করুন' : '৪ বা ততোধিক ডিজিটের পিন দিন')
                  : 'আপনার পিন লিখুন',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 12,
              decoration: const InputDecoration(
                labelText: 'পিন',
                counterText: '',
              ),
              onSubmitted: (_) => _onSubmit(),
            ),
            if (widget.setupMode && _confirmPhase) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 12,
                decoration: const InputDecoration(
                  labelText: 'পিন নিশ্চিত করুন',
                  counterText: '',
                ),
                onSubmitted: (_) => _onSubmit(),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _onSubmit,
              child: Text(widget.setupMode ? (_confirmPhase ? 'পিন সেভ করুন' : 'পরবর্তী') : 'আনলক'),
            ),
          ],
        ),
      ),
    );
  }
}
