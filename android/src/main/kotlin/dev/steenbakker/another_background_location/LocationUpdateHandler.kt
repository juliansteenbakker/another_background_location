package dev.steenbakker.another_background_location

import android.location.Location
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class LocationUpdateHandler(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding): EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val eventChannel = EventChannel(
        flutterPluginBinding.binaryMessenger,
        "dev.steenbakker.background_location/events"
    )

    init {
        eventChannel.setStreamHandler(this)
    }

    private fun locationToMap(location: Location): Map<String, Any> {
        val locationMap = HashMap<String, Any>()
        locationMap["latitude"] = location.latitude
        locationMap["longitude"] = location.longitude
        locationMap["altitude"] = location.altitude
        locationMap["accuracy"] = location.accuracy.toDouble()
        locationMap["bearing"] = location.bearing.toDouble()
        locationMap["speed"] = location.speed.toDouble()
        locationMap["time"] = location.time.toDouble()
        locationMap["is_mock"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            location.isMock
        } else {
            @Suppress("DEPRECATION")
            location.isFromMockProvider
        }
        return locationMap
    }

    fun publishLocationUpdate(location: Location) {
        val locationMap = locationToMap(location)
        Log.d("ANDROID", "Sending location to flutter")
        eventSink?.success(locationMap)
    }

    override fun onListen(event: Any?, eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    override fun onCancel(event: Any?) {
        this.eventSink = null
    }
}