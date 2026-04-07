package com.gorecalloa.app

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val DEVICE_ID_CHANNEL = "app_not/device_id"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_ID_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidId" -> {
                    val androidId = Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ANDROID_ID
                    )?.trim()

                    if (androidId.isNullOrEmpty()) {
                        result.success(null)
                    } else {
                        result.success("android-$androidId")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
