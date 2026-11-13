package com.example.template

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.rememberNavController
import com.example.template.feature.home.HomeRoute
import com.example.template.feature.home.homeScreen

/**
 * Root navigation graph: the only place that knows every feature. Each feature exposes a route
 * and a `NavGraphBuilder.<feature>Screen(...)` extension; navigation between features happens
 * here through the callbacks those extensions take.
 */
@Composable
fun AppNavHost(modifier: Modifier = Modifier) {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = HomeRoute, modifier = modifier) {
        homeScreen()
    }
}
