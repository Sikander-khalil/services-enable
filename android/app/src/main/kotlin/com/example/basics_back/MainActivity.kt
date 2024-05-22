package com.example.basics_back

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    private lateinit var forServices: Intent

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        forServices = Intent(this, MyServices::class.java)
        flutterEngine?.let {
            MethodChannel(it.dartExecutor.binaryMessenger, "com.example.basics_back").setMethodCallHandler { call, result ->
                if (call.method == "startService") {
                    startServices()
                    result.success("Services Started")
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!isIgnoringBatteryOptimizations()) {
                promptForBatteryOptimization()
            }
        }
    }

    private fun startServices() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forServices)
        } else {
            startService(forServices)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    @SuppressLint("ServiceCast")
    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun promptForBatteryOptimization() {
        AlertDialog.Builder(this)
                .setTitle("Ignore Battery Optimization")
                .setMessage("Please allow this app to ignore battery optimizations to ensure the background service runs continuously.")
                .setPositiveButton("Allow") { _, _ ->
                    val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    startActivity(intent)
                }
                .setNegativeButton("Cancel", null)
                .show()
    }
}
