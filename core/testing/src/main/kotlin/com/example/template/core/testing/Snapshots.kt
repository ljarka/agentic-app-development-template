package com.example.template.core.testing

import androidx.compose.runtime.Composable
import app.cash.paparazzi.DeviceConfig
import app.cash.paparazzi.Paparazzi
import com.android.resources.NightMode
import com.example.template.core.ui.theme.AppTheme
import java.util.Locale

/**
 * The one way to create a Paparazzi rule in this project: same device, same tolerance everywhere.
 *
 * ```
 * @get:Rule val paparazzi = appPaparazzi()
 * @Test fun empty() = paparazzi.snap { HomeContent(...) }
 * @Test fun emptyDark() = paparazzi.snap(dark = true) { HomeContent(...) }
 * ```
 */
fun appPaparazzi(device: DeviceConfig = DeviceConfig.PIXEL_6): Paparazzi =
    Paparazzi(deviceConfig = device, maxPercentDifference = 0.1)

/**
 * Snapshot [content] in [AppTheme] under a fixed runtime: explicit night mode, English locale,
 * no dynamic color. Pass fixed times/data to the composable; never read the clock in a snapshot.
 */
fun Paparazzi.snap(
    dark: Boolean = false,
    device: DeviceConfig = DeviceConfig.PIXEL_6,
    content: @Composable () -> Unit,
) {
    val previousLocale = Locale.getDefault()
    Locale.setDefault(Locale.ENGLISH)
    unsafeUpdateConfig(device.copy(nightMode = if (dark) NightMode.NIGHT else NightMode.NOTNIGHT))
    try {
        snapshot {
            AppTheme(darkTheme = dark, dynamicColor = false) { content() }
        }
    } finally {
        Locale.setDefault(previousLocale)
    }
}
