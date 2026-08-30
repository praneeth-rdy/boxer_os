package com.prdy.boxer_os

import android.app.WallpaperManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val mainThread = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    SET_WALLPAPER -> onSetWallpaper(call, result)
                    SAVE_ROTATION -> onSaveRotation(call, result)
                    OPEN_PICKER -> result.success(openLiveWallpaperPicker())
                    IS_LIVE_ACTIVE -> result.success(isLiveWallpaperActive())
                    else -> result.notImplemented()
                }
            }
    }

    private fun onSetWallpaper(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val target = call.argument<String>("target")
        if (bytes == null || target == null) {
            result.error(FAILED, "Missing wallpaper arguments", null)
            return
        }
        onBackgroundThread(result) { applyWallpaper(bytes, target) }
    }

    private fun onSaveRotation(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val index = call.argument<Int>("index")
        val count = call.argument<Int>("count")
        if (bytes == null || index == null || count == null) {
            result.error(FAILED, "Missing rotation arguments", null)
            return
        }
        onBackgroundThread(result) { saveRotationFrame(bytes, index, count) }
    }

    /** Runs [work] off the main thread and answers [result] with why it failed, or true. */
    private fun onBackgroundThread(result: MethodChannel.Result, work: () -> String?) {
        Thread {
            val failure = work()
            mainThread.post {
                if (failure == null) {
                    result.success(true)
                } else {
                    result.error(FAILED, failure, null)
                }
            }
        }.start()
    }

    /** Sets the wallpaper and returns why it could not be set, or null on success. */
    private fun applyWallpaper(bytes: ByteArray, target: String): String? =
        try {
            val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            if (bitmap == null) {
                "Could not decode the poster"
            } else {
                WallpaperManager.getInstance(this)
                    .setBitmap(bitmap, null, true, flagsFor(target))
                null
            }
        } catch (error: Throwable) {
            error.message ?: "Could not set the wallpaper"
        }

    /** Stores one rotation poster as a JPEG and returns why it could not be stored, or null. */
    private fun saveRotationFrame(bytes: ByteArray, index: Int, count: Int): String? =
        try {
            val folder = GymWallService.folderOf(this)
            if (index == 0) {
                folder.listFiles()?.forEach(File::delete)
            }
            folder.mkdirs()
            val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            if (bitmap == null) {
                "Could not decode the poster"
            } else {
                File(folder, GymWallService.frameName(index)).outputStream().use { file ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, JPEG_QUALITY, file)
                }
                bitmap.recycle()
                if (index == count - 1) {
                    finishRotation(count)
                }
                null
            }
        } catch (error: Throwable) {
            error.message ?: "Could not save the poster"
        }

    private fun finishRotation(count: Int) {
        getSharedPreferences(GymWallService.PREFS, MODE_PRIVATE)
            .edit()
            .putInt(GymWallService.COUNT_KEY, count)
            .putInt(GymWallService.INDEX_KEY, 0)
            .apply()
    }

    private fun openLiveWallpaperPicker(): Boolean =
        try {
            val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
                .putExtra(
                    WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                    gymWallComponent(),
                )
            startActivity(intent)
            true
        } catch (error: ActivityNotFoundException) {
            false
        }

    private fun isLiveWallpaperActive(): Boolean =
        try {
            WallpaperManager.getInstance(this).wallpaperInfo?.component == gymWallComponent()
        } catch (error: Throwable) {
            false
        }

    private fun gymWallComponent() = ComponentName(this, GymWallService::class.java)

    private fun flagsFor(target: String): Int =
        when (target) {
            "home" -> WallpaperManager.FLAG_SYSTEM
            "lock" -> WallpaperManager.FLAG_LOCK
            else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
        }

    private companion object {
        const val CHANNEL = "boxer_os/wallpaper"
        const val SET_WALLPAPER = "setWallpaper"
        const val SAVE_ROTATION = "saveRotation"
        const val OPEN_PICKER = "openLiveWallpaperPicker"
        const val IS_LIVE_ACTIVE = "isLiveWallpaperActive"
        const val FAILED = "wallpaper_failed"
        const val JPEG_QUALITY = 90
    }
}
