package com.example.obd_app.obd_app

import com.example.obd_app.obd_app.car.PidDataStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val carPidChannelName = "com.example.obd_app/car_pids"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, carPidChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updatePids" -> {
                        @Suppress("UNCHECKED_CAST")
                        val values = call.arguments as? Map<String, String> ?: emptyMap()
                        PidDataStore.update(values)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
