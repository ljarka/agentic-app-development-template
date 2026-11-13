package com.example.template.core.model

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class PollingTest {

    @Test
    fun fixedDelayRunsOncePerInterval() = runTest {
        var runs = 0
        val job = launch { pollEvery(intervalMillis = 1_000) { runs++ } }
        runCurrent()
        assertEquals(1, runs)
        advanceTimeBy(1_000)
        runCurrent()
        assertEquals(2, runs)
        job.cancel()
    }

    @Test
    fun startToStartSubtractsRunTimeButKeepsMinimum() {
        assertEquals(
            700,
            nextPollDelayMillis(1_000, elapsedMillis = 300, minDelayMillis = 100, includeRunTimeInInterval = true),
        )
        assertEquals(
            100,
            nextPollDelayMillis(1_000, elapsedMillis = 990, minDelayMillis = 100, includeRunTimeInInterval = true),
        )
        assertEquals(
            1_000,
            nextPollDelayMillis(1_000, elapsedMillis = 990, minDelayMillis = 100, includeRunTimeInInterval = false),
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun rejectsNonPositiveInterval() = runTest {
        pollEvery(intervalMillis = 0) {}
    }
}
