package com.example.template.feature.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.template.core.ui.theme.Dimens

/** Stateful entry point: gets the ViewModel, hands plain state to [HomeContent]. */
@Composable
fun HomeScreen(viewModel: HomeViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    HomeContent(state)
}

/** Stateless UI: everything it shows comes in as parameters, so screenshot tests can render it. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeContent(state: HomeUiState, modifier: Modifier = Modifier) {
    Scaffold(
        modifier = modifier,
        topBar = { TopAppBar(title = { Text(stringResource(R.string.home_title)) }) },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).padding(Dimens.SpaceM),
            verticalArrangement = Arrangement.spacedBy(Dimens.SpaceM),
        ) {
            Text(
                text = stringResource(state.partOfDay.greeting()),
                style = MaterialTheme.typography.headlineMedium,
            )
            Card {
                Column(Modifier.padding(Dimens.SpaceM), verticalArrangement = Arrangement.spacedBy(Dimens.SpaceS)) {
                    Text(stringResource(R.string.home_card_title), style = MaterialTheme.typography.titleMedium)
                    Text(
                        stringResource(R.string.home_card_body),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}

private fun PartOfDay.greeting(): Int = when (this) {
    PartOfDay.MORNING -> R.string.home_greeting_morning
    PartOfDay.AFTERNOON -> R.string.home_greeting_afternoon
    PartOfDay.EVENING -> R.string.home_greeting_evening
    PartOfDay.NIGHT -> R.string.home_greeting_night
}
