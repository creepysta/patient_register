package com.example.patient_register


import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Context
import android.content.ContextWrapper
import android.content.IntentFilter
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.work.*
import com.google.common.util.concurrent.ListenableFuture
import java.util.concurrent.TimeUnit


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.patient_register/service"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        val constraints = Constraints.Builder()
//            .setRequiresBatteryNotLow(true)
//            .build()
//        val backupRequest = PeriodicWorkRequestBuilder<BackupWorker>(15, TimeUnit.MINUTES)
//            .setConstraints(constraints)
//            .build()

//        WorkManager.getInstance(applicationContext).enqueueUniquePeriodicWork(
//            "backupDb",
//            ExistingPeriodicWorkPolicy.KEEP,
//            backupRequest
//        )
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getService") {
                val param = call.argument<String>("url")
                startService()
                val statuses: ListenableFuture<List<WorkInfo>> =
                    WorkManager.getInstance(applicationContext).getWorkInfosByTag(
                        TAG_WORKER
                    )
                val infos : List<WorkInfo> = statuses.get();
                Log.d("MYEDBUG", "Workers currently present ${infos.size}")
                Log.d("MYEDBUG", "Parameter passed: $param")
                result.success("Method Channel Worked")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startService() {
//        val constraints = Constraints.Builder()
//            .setRequiresBatteryNotLow(true)
//            .build()
//        val backupRequest = OneTimeWorkRequestBuilder<BackupWorker>()
//            .setConstraints(constraints).addTag(TAG_WORKER)
//            .build()
        WorkManager.getInstance(applicationContext).enqueueUniqueWork(
            TAG_WORKER,
            ExistingWorkPolicy.KEEP,
            backupRequest
        )
    }

    companion object {
        const val TAG_WORKER = "backupDb"
        private val constraints = Constraints.Builder()
            .setRequiresBatteryNotLow(true)
            .build()
        private val backupRequest = OneTimeWorkRequestBuilder<BackupWorker>()
            .setConstraints(constraints).addTag(TAG_WORKER)
            .build()
    }
}


//
//package com.example.patient_register;
//
//import android.content.pm.PackageInfo;
//import android.content.pm.PackageManager;
//import android.os.Environment;
//import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.plugin.common.MethodChannel;
//import com.example.patient_register.MainActivity;
//import io.flutter.Log;
//import io.flutter.embedding.android.FlutterActivity;
//import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
//import io.flutter.plugin.common.MethodCall;
//import java.io.File;
//import java.io.FileInputStream;
//import java.io.FileOutputStream;
//import java.io.IOException;
//import java.lang.Exception;
//import java.nio.channels.FileChannel;
//
//class MainActivity : FlutterActivity() {
//    // dont even need this bull shit :)ss
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
//                    // Note: this method is invoked on the main thread.
//                    if (call.method == "backupDb") {
//                        val res = backupDb()
//                        if (res == -1) {
//                            result.error("Backup failed", "failed to export daatabase", null)
//                        } else {
//                            result.success(res)
//                        }
//                    } else if (call.method == "importDb") {
//                        val res = importDb()
//                        if (res == -1) {
//                            result.error("Import failed", "failed to import daatabase", null)
//                        } else {
//                            result.success(res)
//                        }
//                    } else {
//                        result.notImplemented()
//                    }
//                }
//    }
//
//    private fun backupDb(): Int {
//        val m = packageManager
//        val s = packageName
//        var p: PackageInfo? = null
//        p = try {
//            m.getPackageInfo(s, 0)
//        } catch (e: Exception) {
//            print(e)
//            return -1
//        }
//        val sd = Environment.getExternalStorageDirectory()
//        val data = Environment.getDataDirectory()
//        var source: FileChannel? = null
//        var destination: FileChannel? = null
//        val currentDBPath = p.applicationInfo.dataDir
//        val backupDBPath = "PatientRegister (database backup)"
//        val currentDB = File(data, currentDBPath)
//        val backupDB = File(sd, backupDBPath)
//        try {
//            source = FileInputStream(currentDB).channel
//            destination = FileOutputStream(backupDB).channel
//            destination.transferFrom(source, 0, source.size())
//            source.close()
//            destination.close()
//        } catch (e: IOException) {
//            e.printStackTrace()
//            return -1
//        }
//        return 1
//    }
//
//    private fun importDb(): Int {
//        val m = packageManager
//        var s = packageName
//        s = try {
//            val p = m.getPackageInfo(s, 0)
//            p.applicationInfo.dataDir
//        } catch (e: PackageManager.NameNotFoundException) {
//            Log.w("yourtag", "Error Package name not found ", e)
//            return -1
//        }
//        return 1
//    }
//
//    companion object {
//        private const val CHANNEL = "samples.flutter.dev/battery"
//    }
//}