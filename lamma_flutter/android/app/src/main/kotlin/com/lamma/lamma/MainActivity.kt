package com.lamma.lamma

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File
import java.security.MessageDigest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.lamma.lamma/updates")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "appInfo" -> {
                            val info = packageManager.getPackageInfo(packageName, 0)
                            result.success(mapOf("version" to info.versionName, "buildNumber" to versionCode(info)))
                        }
                        "canInstall" -> result.success(canInstall())
                        "requestInstallPermission" -> {
                            if (Build.VERSION.SDK_INT >= 26 && !canInstall()) {
                                startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName")))
                            }
                            result.success(null)
                        }
                        "install" -> {
                            if (!canInstall()) {
                                result.error("permission", "اسمح بتثبيت التحديثات من لَمّة أولًا.", null)
                                return@setMethodCallHandler
                            }
                            val root = File(cacheDir, "app_updates").canonicalFile
                            val apk = File(requireNotNull(call.argument<String>("path"))).canonicalFile
                            require(apk.parentFile == root && apk.name == "update.apk" && apk.isFile) { "Invalid APK cache path" }
                            val flags = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
                            val archive = requireNotNull(packageManager.getPackageArchiveInfo(apk.path, flags)) { "Invalid APK" }
                            val installed = packageManager.getPackageInfo(packageName, flags)
                            val expected = requireNotNull(call.argument<Number>("buildNumber")).toLong()
                            require(archive.packageName == packageName && versionCode(archive) == expected && expected > versionCode(installed)) { "APK package/version mismatch" }
                            require(signers(archive).isNotEmpty() && signers(archive) == signers(installed)) { "APK signing certificate mismatch" }
                            val uri = FileProvider.getUriForFile(this, "$packageName.updates", apk)
                            startActivity(Intent(Intent.ACTION_VIEW).setDataAndType(uri, "application/vnd.android.package-archive")
                                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
                            // Android owns the consent/install result. Opening its UI is not installation success.
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("update_error", error.message ?: "تعذر فتح تثبيت التحديث.", null)
                }
            }
    }
    private fun canInstall(): Boolean = Build.VERSION.SDK_INT < 26 || packageManager.canRequestPackageInstalls()
    @Suppress("DEPRECATION")
    private fun versionCode(info: PackageInfo): Long = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
    @Suppress("DEPRECATION")
    private fun signers(info: PackageInfo): Set<String> {
        val signatures = if (Build.VERSION.SDK_INT >= 28) info.signingInfo?.apkContentsSigners else info.signatures
        return signatures?.map { signature ->
            MessageDigest.getInstance("SHA-256").digest(signature.toByteArray()).joinToString("") { "%02x".format(it) }
        }?.toSet() ?: emptySet()
    }
}
