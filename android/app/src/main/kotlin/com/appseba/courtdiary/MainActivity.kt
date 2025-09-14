package com.appseba.courtdiary

import io.flutter.embedding.android.FlutterFragmentActivity

// Use FlutterFragmentActivity because local_auth (BiometricPrompt/device credentials)
// requires a FragmentActivity host on Android.
class MainActivity : FlutterFragmentActivity()
