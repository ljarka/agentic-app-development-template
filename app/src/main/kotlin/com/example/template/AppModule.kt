package com.example.template

import com.example.template.core.model.TimeSource
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import java.time.LocalDateTime

/**
 * Composition root for cross-module contracts (`:core:model` interfaces). Bind here what no
 * single feature owns; a contract owned by a feature is bound in that feature's Hilt module.
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    @Provides
    fun timeSource(): TimeSource = TimeSource { LocalDateTime.now() }
}
