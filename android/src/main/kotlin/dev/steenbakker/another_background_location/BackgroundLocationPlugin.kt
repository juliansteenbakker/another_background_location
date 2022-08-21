package dev.steenbakker.another_background_location

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class BackgroundLocationPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private var manager: BackgroundLocationManager? = null

    private lateinit var channel: MethodChannel

    companion object {
        const val TAG = "dev.steenbakker.Log.Tag"
        const val PLUGIN_ID = "dev.steenbakker.background_location"
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (manager == null) {
            result.error("Not initialized", "BackgroundLocationManager is not correctly initialized", null)
        }
        when (call.method) {
            "get_current_location" -> manager!!.requestCurrentLocation(result)
            "start_location_service" -> manager!!.startLocationService(result, call.argument("distance_filter"), call.argument("force_location_manager"))
            "stop_location_service" -> manager!!.stopLocationService(result)
            "set_android_notification" -> manager!!.setAndroidNotification(result, call.argument("title"),call.argument("message"),call.argument("icon"))
            "set_configuration" -> manager!!.setConfiguration(result, call.argument<String>("interval")?.toLongOrNull())
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, BackgroundLocationManager.METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        manager = BackgroundLocationManager(binding.applicationContext, LocationUpdateHandler(binding))
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
//        manager.onDetachedFromEngine()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        manager?.activity = binding.activity
        binding.addRequestPermissionsResultListener { requestCode, test, grantResults ->
            when (requestCode) {
                BackgroundLocationManager.REQUEST_PERMISSIONS_REQUEST_CODE -> {
                    if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                        service?.requestLocationUpdates()  TODO
                        return@addRequestPermissionsResultListener true
                    } else {
                        if (grantResults.isEmpty()) {
                            Log.i(BackgroundLocationPlugin.TAG, "User interaction was cancelled.")
                        }
                        return@addRequestPermissionsResultListener false
                    }
                }
                else ->  return@addRequestPermissionsResultListener false
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        manager?.activity = null
    }

}
