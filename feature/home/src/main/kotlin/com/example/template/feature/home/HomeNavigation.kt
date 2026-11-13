package com.example.template.feature.home

import androidx.navigation.NavGraphBuilder
import androidx.navigation.compose.composable
import kotlinx.serialization.Serializable

/** Navigation contract of this feature: `:app` adds [homeScreen] to its NavHost. */
@Serializable
object HomeRoute

fun NavGraphBuilder.homeScreen() {
    composable<HomeRoute> { HomeScreen() }
}
