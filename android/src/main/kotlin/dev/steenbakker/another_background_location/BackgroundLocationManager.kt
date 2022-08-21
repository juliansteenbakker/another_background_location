package dev.steenbakker.another_background_location

import android.Manifest

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.*
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*


class BackgroundLocationManager(private val context: Context, val locationUpdateHandler: LocationUpdateHandler) {

    companion object {
        const val METHOD_CHANNEL_NAME = "${BackgroundLocationPlugin.PLUGIN_ID}/methods"
        internal const val REQUEST_PERMISSIONS_REQUEST_CODE = 34
    }

    /**
     * Context that is set once attached to a FlutterEngine.
     * Context should no longer be referenced when detached.
     */
    var activity: Activity? = null

    private val receiver: MyReceiver = MyReceiver()
    private var service: LocationUpdatesService? = null

    /**
     * Signals whether the LocationUpdatesService is bound
     */
    private var bound: Boolean = false

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, service: IBinder) {
            bound = true
            val binder = service as LocationUpdatesService.LocalBinder
            this@BackgroundLocationManager.service = binder.service
            requestLocation()
        }

        override fun onServiceDisconnected(name: ComponentName) {
            service = null
        }
    }

    fun startLocationService(result: MethodChannel.Result, distanceFilter: Double?, forceLocationManager : Boolean?) {
        LocalBroadcastManager.getInstance(context).registerReceiver(receiver,
            IntentFilter(LocationUpdatesService.ACTION_BROADCAST))
        if (!bound) {
            val intent = Intent(context, LocationUpdatesService::class.java)
            intent.putExtra("distance_filter", distanceFilter)
            intent.putExtra("force_location_manager", forceLocationManager)
            context.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
        }

        result.success(null)
    }

    fun stopLocationService(result: MethodChannel.Result,) {
        service?.removeLocationUpdates()
        LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)

        if (bound) {
            context.unbindService(serviceConnection)
            bound = false
        }

        result.success(null)
    }

    fun setAndroidNotification(result: MethodChannel.Result, title: String?, message: String?, icon: String?) {
        if (title != null) LocationUpdatesService.NOTIFICATION_TITLE = title
        if (message != null) LocationUpdatesService.NOTIFICATION_MESSAGE = message
        if (icon != null) LocationUpdatesService.NOTIFICATION_ICON = icon

        if (service != null) {
            service?.updateNotification()
        }

        result.success(null)
    }

    fun setConfiguration(result: MethodChannel.Result, timeInterval: Long?) {
        if (timeInterval != null) LocationUpdatesService.UPDATE_INTERVAL_IN_MILLISECONDS = timeInterval

        result.success(null)
    }

    /**
     * Requests a location updated.
     * If permission is denied, it requests the needed permission
     */
    private fun requestLocation() {
        if (!checkPermissions()) {
            requestPermissions()
        } else {
            service?.requestLocationUpdates()
        }
    }

    /**
     * Requests a location updated.
     * If permission is denied, it requests the needed permission
     */
    fun requestCurrentLocation(result: MethodChannel.Result) {
        if (!checkPermissions()) {
            requestPermissions()
        } else {
            val location = service?.getCurrentLocation()
            if (location == null) {
                result.error("Location Failed", "Could not get location.", null)
            } else {
                result.success(locationToMap(location))
            }
        }
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

    /**
     * Checks the current permission for `ACCESS_FINE_LOCATION`
     */
    private fun checkPermissions(): Boolean {
        return ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Requests permission for location.
     * Depending on the current activity, displays a rationale for the request.
     */
    private fun requestPermissions() {
        if(activity == null) return

        val shouldProvideRationale = ActivityCompat.shouldShowRequestPermissionRationale(activity!!, Manifest.permission.ACCESS_FINE_LOCATION)
        if (shouldProvideRationale) {
            Log.i(BackgroundLocationPlugin.TAG, "Displaying permission rationale to provide additional context.")
            Toast.makeText(context, R.string.permission_rationale, Toast.LENGTH_LONG).show()
        } else {
            Log.i(BackgroundLocationPlugin.TAG, "Requesting permission")
            ActivityCompat.requestPermissions(activity!!,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                REQUEST_PERMISSIONS_REQUEST_CODE
            )
        }
    }

    /**
     * Enables bluetooth with a dialog or without.
     */
//    fun enableBluetooth(call: MethodCall, result: MethodChannel.Result, activityBinding: ActivityPluginBinding) {
//        if (mBluetoothManager!!.adapter.isEnabled) {
//            result.success(true)
//        } else {
//            if (call.arguments as Boolean) {
//                pendingResultForActivityResult = result
//                val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
//                ActivityCompat.startActivityForResult(
//                    activityBinding.activity,
//                    intent,
//                    requestEnableBt,
//                    null
//                )
//            } else {
//                mBluetoothManager!!.adapter.enable()
//            }
//        }
//    }

    private inner class MyReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val location: Location? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(LocationUpdatesService.EXTRA_LOCATION, Location::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(LocationUpdatesService.EXTRA_LOCATION)
            }
            if (location != null) {
                locationUpdateHandler.publishLocationUpdate(location)
            }
        }
    }

}