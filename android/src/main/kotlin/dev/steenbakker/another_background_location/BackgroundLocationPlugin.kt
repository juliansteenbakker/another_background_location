package dev.steenbakker.another_background_location

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


class BackgroundLocationPlugin : FlutterPlugin, ActivityAware {
    private var activity: ActivityPluginBinding? = null
    private var manager: BackgroundLocationManager = BackgroundLocationManager()

    companion object {
        const val TAG = "dev.steenbakker.Log.Tag"
        const val PLUGIN_ID = "dev.steenbakker.background_location"
    }


    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        manager.onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        manager.onDetachedFromEngine()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        manager.setActivity(binding)
        binding.addRequestPermissionsResultListener(manager)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        manager.setActivity(null)
    }

}
