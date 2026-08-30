package com.prdy.boxer_os

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.os.SystemClock
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import java.io.File
import java.util.Locale
import kotlin.math.max
import kotlin.math.roundToInt

/** Live wallpaper that shows the next Boxer OS poster every time the screen wakes. */
class GymWallService : WallpaperService() {

    override fun onCreateEngine(): Engine = GymWallEngine()

    private inner class GymWallEngine : Engine() {
        private val paint = Paint(Paint.FILTER_BITMAP_FLAG)
        private var surfaceWidth = 0
        private var surfaceHeight = 0

        override fun onVisibilityChanged(visible: Boolean) {
            if (!visible) {
                return
            }
            advance()
            draw()
        }

        override fun onSurfaceChanged(
            holder: SurfaceHolder,
            format: Int,
            width: Int,
            height: Int,
        ) {
            surfaceWidth = width
            surfaceHeight = height
            draw()
        }

        override fun onSurfaceRedrawNeeded(holder: SurfaceHolder) {
            draw()
        }

        private fun advance() {
            val prefs = prefs()
            val count = prefs.getInt(COUNT_KEY, 0)
            if (count <= 0) {
                return
            }
            val next = (prefs.getInt(INDEX_KEY, 0) + 1) % count
            prefs.edit().putInt(INDEX_KEY, next).apply()
        }

        private fun draw() {
            if (surfaceWidth <= 0 || surfaceHeight <= 0) {
                return
            }
            val started = SystemClock.elapsedRealtime()
            val poster = loadPoster()
            var canvas: Canvas? = null
            try {
                canvas = surfaceHolder.lockCanvas()
                if (canvas == null) {
                    return
                }
                if (poster == null) {
                    canvas.drawColor(INK)
                } else {
                    canvas.drawBitmap(poster, cropOf(poster), surfaceRect(), paint)
                }
            } catch (error: Throwable) {
                Log.d(TAG, "draw failed: ${error.message}")
            } finally {
                if (canvas != null) {
                    releaseCanvas(canvas)
                }
                poster?.recycle()
            }
            Log.d(TAG, "drew in ${SystemClock.elapsedRealtime() - started} ms")
        }

        private fun releaseCanvas(canvas: Canvas) {
            try {
                surfaceHolder.unlockCanvasAndPost(canvas)
            } catch (error: IllegalStateException) {
                Log.d(TAG, "surface gone: ${error.message}")
            }
        }

        /** The poster the stored index points at, or null when there is nothing to show. */
        private fun loadPoster(): Bitmap? {
            val prefs = prefs()
            val count = prefs.getInt(COUNT_KEY, 0)
            if (count <= 0) {
                return null
            }
            val file = File(folderOf(this@GymWallService), frameName(prefs.getInt(INDEX_KEY, 0) % count))
            if (!file.exists()) {
                return null
            }
            return try {
                val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(file.path, bounds)
                val options = BitmapFactory.Options().apply {
                    inSampleSize = sampleSizeFor(bounds.outWidth, bounds.outHeight)
                }
                BitmapFactory.decodeFile(file.path, options)
            } catch (error: Throwable) {
                Log.d(TAG, "decode failed: ${error.message}")
                null
            }
        }

        private fun sampleSizeFor(width: Int, height: Int): Int {
            var sample = 1
            while (
                width / (sample * 2) >= surfaceWidth && height / (sample * 2) >= surfaceHeight
            ) {
                sample *= 2
            }
            return sample
        }

        private fun surfaceRect() = Rect(0, 0, surfaceWidth, surfaceHeight)

        /** The centre-cropped part of [poster] that fills the surface. */
        private fun cropOf(poster: Bitmap): Rect {
            val scale = max(
                surfaceWidth.toFloat() / poster.width,
                surfaceHeight.toFloat() / poster.height,
            )
            val width = (surfaceWidth / scale).roundToInt().coerceIn(1, poster.width)
            val height = (surfaceHeight / scale).roundToInt().coerceIn(1, poster.height)
            val left = (poster.width - width) / 2
            val top = (poster.height - height) / 2
            return Rect(left, top, left + width, top + height)
        }

        private fun prefs() =
            getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    }

    companion object {
        const val PREFS = "gym_wall"
        const val COUNT_KEY = "gym_wall_count"
        const val INDEX_KEY = "gym_wall_index"

        private const val TAG = "GymWall"
        private const val FOLDER = "gym_wall"
        private const val INK = 0xFF0A0A0B.toInt()

        /** Where the rendered posters live. */
        fun folderOf(context: Context) = File(context.filesDir, FOLDER)

        fun frameName(index: Int) = String.format(Locale.US, "%03d.jpg", index)
    }
}
