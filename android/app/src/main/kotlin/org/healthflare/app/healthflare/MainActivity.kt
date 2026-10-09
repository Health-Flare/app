package org.healthflare.app.healthflare

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity, not FlutterActivity: local_auth shows the
// biometric/passcode prompt as a fragment (app lock, #100).
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Hide in app switcher (#101). FLAG_SECURE blanks the recents
        // thumbnail and also blocks screenshots and screen recording; Android
        // has no way to do one without the other. See
        // lib/core/security/secure_window.dart.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "org.healthflare.app/secure_window",
        ).setMethodCallHandler { call, result ->
            if (call.method != "setHidden") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val hidden = call.argument<Boolean>("hidden") ?: false
            runOnUiThread {
                if (hidden) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            }
        }
    }
}
