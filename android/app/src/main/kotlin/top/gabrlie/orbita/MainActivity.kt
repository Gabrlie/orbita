package top.gabrlie.orbita

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import top.gabrlie.orbita.tailproxy.Tailproxy

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "top.gabrlie.orbita/tailnet",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> runTailnet(result) {
                    Tailproxy.start(tailnetStateDir())
                }
                "status" -> runTailnet(result) {
                    Tailproxy.status()
                }
                "authUrl" -> runTailnet(result) {
                    Tailproxy.authURL()
                }
                "openUrl" -> openExternalUrl(
                    call.argument<String>("url").orEmpty(),
                    result,
                )
                "listPeers" -> runTailnet(result) {
                    Tailproxy.listPeers()
                }
                "openTcpProxy" -> runTailnet(result) {
                    val target = call.argument<String>("target").orEmpty()
                    val port = call.argument<Int>("port") ?: 22
                    Tailproxy.openTCPProxy(target, port.toLong())
                }
                "closeProxy" -> runTailnet(result) {
                    Tailproxy.closeProxy(call.argument<String>("id").orEmpty())
                    null
                }
                "stop" -> runTailnet(result) {
                    Tailproxy.stop()
                    null
                }
                "clearState" -> runTailnet(result) {
                    Tailproxy.clearState()
                    null
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun tailnetStateDir(): String {
        return java.io.File(filesDir, "orbita_tailnet_state").absolutePath
    }

    private fun openExternalUrl(url: String, result: MethodChannel.Result) {
        try {
            if (url.isBlank()) {
                result.error("TAILNET_ERROR", "url is required", null)
                return
            }
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
            result.success(null)
        } catch (error: Throwable) {
            result.error("TAILNET_ERROR", error.message ?: error.toString(), null)
        }
    }

    private fun runTailnet(
        result: MethodChannel.Result,
        block: () -> Any?,
    ) {
        Thread {
            try {
                val value = block()
                runOnUiThread { result.success(value) }
            } catch (error: Throwable) {
                runOnUiThread {
                    result.error(
                        "TAILNET_ERROR",
                        error.message ?: error.toString(),
                        null,
                    )
                }
            }
        }.start()
    }
}
