package com.example.garda

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val shareChannel = "garda/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannel).setMethodCallHandler { call, result ->
            if (call.method == "shareText") {
                val title = call.argument<String>("title") ?: "Bagikan"
                val text = call.argument<String>("text").orEmpty()
                val sendIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                }

                startActivity(Intent.createChooser(sendIntent, title))
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
