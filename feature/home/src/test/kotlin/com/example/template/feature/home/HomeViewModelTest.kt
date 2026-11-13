package com.example.template.feature.home

import java.time.LocalDateTime
import org.junit.Assert.assertEquals
import org.junit.Test

class HomeViewModelTest {

    private fun stateAt(hour: Int) = HomeViewModel { LocalDateTime.of(2026, 1, 1, hour, 0) }.uiState.value

    @Test
    fun greetingFollowsInjectedTime() {
        assertEquals(PartOfDay.MORNING, stateAt(8).partOfDay)
        assertEquals(PartOfDay.AFTERNOON, stateAt(12).partOfDay)
        assertEquals(PartOfDay.EVENING, stateAt(22).partOfDay)
        assertEquals(PartOfDay.NIGHT, stateAt(23).partOfDay)
        assertEquals(PartOfDay.NIGHT, stateAt(4).partOfDay)
    }
}
