package com.example.template.feature.home

import com.example.template.core.testing.appPaparazzi
import com.example.template.core.testing.snap
import org.junit.Rule
import org.junit.Test

/**
 * Screenshots of every distinct state, light and dark. After an intentional UI change:
 * `./gradlew :feature:home:recordPaparazziDebug`, then review the PNGs in src/test/snapshots.
 */
class HomeScreenshotTest {

    @get:Rule
    val paparazzi = appPaparazzi()

    @Test
    fun morning() = paparazzi.snap { HomeContent(HomeUiState(PartOfDay.MORNING)) }

    @Test
    fun eveningDark() = paparazzi.snap(dark = true) { HomeContent(HomeUiState(PartOfDay.EVENING)) }
}
