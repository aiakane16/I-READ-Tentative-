package com.example.i_read_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.vosk.Log
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "vosk_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // You can keep this method if you plan to use Vosk in the future
                "startRecognition" -> {
                    result.notImplemented() // This method is not implemented anymore
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // No need to close Vosk resources anymore since we're not using it
    }
}