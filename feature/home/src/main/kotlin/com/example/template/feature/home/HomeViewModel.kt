package com.example.template.feature.home

import androidx.lifecycle.ViewModel
import com.example.template.core.model.TimeSource
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

enum class PartOfDay { MORNING, AFTERNOON, EVENING, NIGHT }

data class HomeUiState(val partOfDay: PartOfDay)

internal fun partOfDay(hour: Int): PartOfDay = when (hour) {
    in 5..11 -> PartOfDay.MORNING
    in 12..17 -> PartOfDay.AFTERNOON
    in 18..22 -> PartOfDay.EVENING
    else -> PartOfDay.NIGHT
}

/**
 * Example ViewModel: one immutable UI state exposed as a StateFlow, inputs injected through
 * `:core:model` contracts ([TimeSource]) so tests control them.
 */
@HiltViewModel
class HomeViewModel @Inject constructor(timeSource: TimeSource) : ViewModel() {
    private val state = MutableStateFlow(HomeUiState(partOfDay(timeSource.now().hour)))
    val uiState: StateFlow<HomeUiState> = state.asStateFlow()
}
