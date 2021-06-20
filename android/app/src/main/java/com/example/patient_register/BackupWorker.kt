package com.example.patient_register


import android.content.Context
import android.util.Log
import androidx.work.*
import java.lang.Exception
import java.lang.Thread.sleep
import java.util.concurrent.TimeUnit

class BackupWorker(appContext : Context, workerParams: WorkerParameters) : Worker (appContext, workerParams) {
    override fun doWork(): Result {
        return try {
            Log.d("MYEDBUG", "Worker being called")
            backupDb()
            Result.success()
        } catch (e : Exception) {
            Log.d("MYEDBUG", "Worker Failed with ${e.message}")
            Result.failure()
        }
    }

    private fun backupDb() {
        Log.d("MYEDBUG", "----------worker called----------")
        sleep(1000);
        Log.d("MYEDBUG", "----------worker call finished after 1 sec----------")
    }
}