package com.example.template.core.model

import java.time.LocalDateTime

/**
 * The current time, injected instead of calling `LocalDateTime.now()` in features, so unit and
 * screenshot tests are deterministic (rule 13 of the playbook). Bound to the system clock in
 * `:app` (`AppModule`); tests pass a fixed lambda.
 */
fun interface TimeSource {
    fun now(): LocalDateTime
}
