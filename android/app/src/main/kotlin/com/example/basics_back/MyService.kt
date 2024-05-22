package com.example.basics_back

import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class MyServices : Service() {

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Ensures the service is restarted if it's killed by the system
        startForegroundService()
        return START_STICKY
    }

    private fun startForegroundService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val builder = NotificationCompat.Builder(this, "message")
                    .setContentText("This is running in Background")
                    .setContentTitle("Flutter Background")
                    .setSmallIcon(R.mipmap.ic_launcher)

            startForeground(101, builder.build())
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
