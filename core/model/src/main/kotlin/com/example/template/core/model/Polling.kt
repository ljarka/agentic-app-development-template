package com.example.template.core.model

import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive

/**
 * Runs [block] until the coroutine is cancelled, with a pause between runs. Use this instead of
 * hand-written infinite `delay()` loops (docs/playbooks/ai-agent-mobile-development.md, rule 11).
 *
 * With [includeRunTimeInInterval] false (default) each run is followed by [intervalMillis].
 * With it true, [intervalMillis] is the start-to-start period, never less than [minDelayMillis].
 */
suspend fun pollEvery(
    intervalMillis: Long,
    minDelayMillis: Long = intervalMillis,
    includeRunTimeInInterval: Boolean = false,
    block: suspend () -> Unit,
) {
    require(intervalMillis > 0) { "intervalMillis must be > 0" }
    require(minDelayMillis > 0) { "minDelayMillis must be > 0" }
    while (currentCoroutineContext().isActive) {
        val startedAtNanos = System.nanoTime()
        block()
        val elapsedMillis = (System.nanoTime() - startedAtNanos) / 1_000_000L
        delay(
            nextPollDelayMillis(
                intervalMillis = intervalMillis,
                elapsedMillis = elapsedMillis,
                minDelayMillis = minDelayMillis,
                includeRunTimeInInterval = includeRunTimeInInterval,
            ),
        )
    }
}

internal fun nextPollDelayMillis(
    intervalMillis: Long,
    elapsedMillis: Long,
    minDelayMillis: Long,
    includeRunTimeInInterval: Boolean,
): Long = if (includeRunTimeInInterval) {
    (intervalMillis - elapsedMillis).coerceAtLeast(minDelayMillis)
} else {
    intervalMillis
}
