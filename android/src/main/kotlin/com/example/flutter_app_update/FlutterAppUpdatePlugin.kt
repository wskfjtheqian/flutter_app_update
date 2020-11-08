package com.example.flutter_app_update

import android.app.Application
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** FlutterAppUpdatePlugin */
class FlutterAppUpdatePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mApplication: Application

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_app_update")
        channel.setMethodCallHandler(this)
        mApplication = flutterPluginBinding.getApplicationContext() as Application
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")

        } else if (call.method == "installApp") {
            try {
                installAppIntent(call.arguments as String)
                result.success(true)
            } catch (e: Exception) {
                result.error(e.toString(), e.toString(), e)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    fun installAppIntent(filePath: String?) {
        val apkfile = File(filePath)
        if (!apkfile.exists()) {
            return
        }
        val intent = Intent(Intent.ACTION_VIEW)
        val contentUri: Uri = getUriForFile(apkfile)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        }
        intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
        mApplication.startActivity(intent)
    }

    private fun getUriForFile(file: File?): Uri {
        if (file == null) {
            throw NullPointerException()
        }
        val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            FileProvider.getUriForFile(mApplication, mApplication.packageName + ".flutter.app_update_provider", file)
        } else {
            Uri.fromFile(file)
        }
        return uri
    }
}
