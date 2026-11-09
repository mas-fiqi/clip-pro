package id.cakfi.quickclippro

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaCodecInfo
import android.media.MediaCodecList
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "id.cakfi.quickclippro/device_capabilities"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceCapabilities" -> {
                    try {
                        val capabilities = getDeviceCapabilities()
                        result.success(capabilities)
                    } catch (e: Exception) {
                        result.error("CAPABILITY_ERROR", e.message, null)
                    }
                }
                "getStorageAndThermalInfo" -> {
                    try {
                        val info = getStorageAndThermalInfo()
                        result.success(info)
                    } catch (e: Exception) {
                        result.error("INFO_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getDeviceCapabilities(): Map<String, Any?> {
        val data = mutableMapOf<String, Any?>()

        // 1. Device Info
        data["deviceModel"] = "${Build.MANUFACTURER} ${Build.MODEL}"
        data["androidVersion"] = Build.VERSION.RELEASE
        data["sdkInt"] = Build.VERSION.SDK_INT
        data["supportedAbis"] = Build.SUPPORTED_ABIS.toList()

        // 2. RAM Info
        try {
            val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager.getMemoryInfo(memInfo)
            data["totalRamMB"] = (memInfo.totalMem / (1024 * 1024)).toInt()
            data["availableRamMB"] = (memInfo.availMem / (1024 * 1024)).toInt()
            data["isLowRam"] = memInfo.lowMemory
        } catch (e: Exception) {
            data["totalRamMB"] = null
            data["availableRamMB"] = null
            data["isLowRam"] = null
        }

        // 3. Storage Info
        try {
            val stat = StatFs(Environment.getDataDirectory().path)
            val availableBytes = stat.availableBytes
            val totalBytes = stat.totalBytes
            data["availableStorageMB"] = (availableBytes / (1024 * 1024)).toInt()
            data["totalStorageMB"] = (totalBytes / (1024 * 1024)).toInt()
        } catch (e: Exception) {
            data["availableStorageMB"] = null
            data["totalStorageMB"] = null
        }

        // 4. Hardware Video Encoders via MediaCodecList
        val encoderList = mutableListOf<Map<String, Any?>>()
        try {
            val mcl = MediaCodecList(MediaCodecList.REGULAR_CODECS)
            for (info in mcl.codecInfos) {
                if (!info.isEncoder) continue

                val supportedTypes = info.supportedTypes
                var isVideoEncoder = false
                for (type in supportedTypes) {
                    if (type.startsWith("video/")) {
                        isVideoEncoder = true
                        break
                    }
                }
                if (!isVideoEncoder) continue

                val isHw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    info.isHardwareAccelerated
                } else {
                    !info.name.startsWith("OMX.google.") && !info.name.startsWith("c2.android.")
                }

                for (mimeType in supportedTypes) {
                    if (!mimeType.startsWith("video/")) continue

                    val codecMap = mutableMapOf<String, Any?>()
                    codecMap["name"] = info.name
                    codecMap["mimeType"] = mimeType
                    codecMap["isHardwareAccelerated"] = isHw

                    try {
                        val caps = info.getCapabilitiesForType(mimeType)
                        val videoCaps = caps.videoCapabilities
                        if (videoCaps != null) {
                            codecMap["maxWidth"] = videoCaps.supportedWidths.upper
                            codecMap["maxHeight"] = videoCaps.supportedHeights.upper
                            codecMap["supportedBitrateRange"] = listOf(
                                videoCaps.bitrateRange.lower,
                                videoCaps.bitrateRange.upper
                            )
                            codecMap["maxFps"] = videoCaps.supportedFrameRates.upper
                        }

                        val colorFormats = caps.colorFormats.toList()
                        codecMap["colorFormats"] = colorFormats
                    } catch (e: Exception) {
                        // ignore capability error for individual codec
                    }

                    encoderList.add(codecMap)
                }
            }
        } catch (e: Exception) {
            // MediaCodecList query failed
        }
        data["videoEncoders"] = encoderList

        return data
    }

    private fun getStorageAndThermalInfo(): Map<String, Any?> {
        val data = mutableMapOf<String, Any?>()

        // 1. Storage
        try {
            val stat = StatFs(Environment.getDataDirectory().path)
            data["availableStorageMB"] = (stat.availableBytes / (1024 * 1024)).toInt()
            data["totalStorageMB"] = (stat.totalBytes / (1024 * 1024)).toInt()
        } catch (e: Exception) {
            data["availableStorageMB"] = null
            data["totalStorageMB"] = null
        }

        // 2. Battery & Temperature
        try {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            if (intent != null) {
                val temp = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
                if (temp != -1) {
                    data["batteryTemperatureCelsius"] = temp / 10.0
                } else {
                    data["batteryTemperatureCelsius"] = null
                }
                val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                if (level != -1 && scale > 0) {
                    data["batteryLevelPercent"] = (level * 100 / scale)
                }
            }
        } catch (e: Exception) {
            data["batteryTemperatureCelsius"] = null
            data["batteryLevelPercent"] = null
        }

        return data
    }
}
