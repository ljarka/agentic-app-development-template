#!/usr/bin/env bash
# Scaffolds a feature module with the project's standard shape (playbook rule 5): route +
# NavGraphBuilder extension, stateful/stateless screen, ViewModel with UiState, a unit test, a
# screenshot test, strings and AGENTS.md. Registers it in settings.gradle.kts and app/build.gradle.kts.
#
#   ./scripts/new-feature.sh <name>          e.g. ./scripts/new-feature.sh shopping
#
# Name: lowercase letters/digits (becomes :feature:<name> and package <base>.feature.<name>).
set -euo pipefail

[ "$#" -eq 1 ] || { echo "Usage: $0 <feature_name>   (e.g. shopping)"; exit 1; }
NAME="$1"
[[ "$NAME" =~ ^[a-z][a-z0-9]*$ ]] || { echo "Name must match ^[a-z][a-z0-9]*$"; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BASE="$(sed -n 's/^project\.basePackage=//p' gradle.properties)"
PKG="$BASE.feature.$NAME"
PKG_DIR="${PKG//.//}"
CLASS="$(tr '[:lower:]' '[:upper:]' <<< "${NAME:0:1}")${NAME:1}"
DIR="feature/$NAME"

[ -d "$DIR" ] && { echo "$DIR already exists"; exit 1; }
echo "Scaffolding :feature:$NAME ($PKG)"
mkdir -p "$DIR/src/main/kotlin/$PKG_DIR" "$DIR/src/test/kotlin/$PKG_DIR" "$DIR/src/main/res/values"
SRC="$DIR/src/main/kotlin/$PKG_DIR"; TEST="$DIR/src/test/kotlin/$PKG_DIR"

cat > "$DIR/build.gradle.kts" <<KTS
plugins {
    id("convention.android.feature")
}

// Common feature dependencies come from the convention plugin (build-logic).
dependencies {
}
KTS

cat > "$SRC/${CLASS}Navigation.kt" <<KT
package $PKG

import androidx.navigation.NavGraphBuilder
import androidx.navigation.compose.composable
import kotlinx.serialization.Serializable

/** Navigation contract of this feature: \`:app\` adds [${NAME}Screen] to its NavHost. */
@Serializable
object ${CLASS}Route

fun NavGraphBuilder.${NAME}Screen() {
    composable<${CLASS}Route> { ${CLASS}Screen() }
}
KT

cat > "$SRC/${CLASS}ViewModel.kt" <<KT
package $PKG

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

sealed interface ${CLASS}UiState {
    data object Loading : ${CLASS}UiState

    data class Ready(val title: String) : ${CLASS}UiState
}

@HiltViewModel
class ${CLASS}ViewModel @Inject constructor() : ViewModel() {
    private val state = MutableStateFlow<${CLASS}UiState>(${CLASS}UiState.Ready(title = "$CLASS"))
    val uiState: StateFlow<${CLASS}UiState> = state.asStateFlow()
}
KT

cat > "$SRC/${CLASS}Screen.kt" <<KT
package $PKG

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import ${BASE}.core.ui.component.LoadingState
import ${BASE}.core.ui.component.MessageState

@Composable
fun ${CLASS}Screen(viewModel: ${CLASS}ViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    ${CLASS}Content(state)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ${CLASS}Content(state: ${CLASS}UiState, modifier: Modifier = Modifier) {
    Scaffold(
        modifier = modifier,
        topBar = { TopAppBar(title = { Text(stringResource(R.string.${NAME}_title)) }) },
    ) { padding ->
        val content = Modifier.fillMaxSize().padding(padding)
        when (state) {
            ${CLASS}UiState.Loading -> LoadingState(content)
            is ${CLASS}UiState.Ready -> MessageState(title = state.title, modifier = content)
        }
    }
}
KT

cat > "$DIR/src/main/res/values/strings.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="${NAME}_title">$CLASS</string>
</resources>
XML

cat > "$TEST/${CLASS}ViewModelTest.kt" <<KT
package $PKG

import org.junit.Assert.assertTrue
import org.junit.Test

class ${CLASS}ViewModelTest {
    @Test
    fun startsReady() {
        assertTrue(${CLASS}ViewModel().uiState.value is ${CLASS}UiState.Ready)
    }
}
KT

cat > "$TEST/${CLASS}ScreenshotTest.kt" <<KT
package $PKG

import ${BASE}.core.testing.appPaparazzi
import ${BASE}.core.testing.snap
import org.junit.Rule
import org.junit.Test

class ${CLASS}ScreenshotTest {
    @get:Rule
    val paparazzi = appPaparazzi()

    @Test
    fun loading() = paparazzi.snap { ${CLASS}Content(${CLASS}UiState.Loading) }

    @Test
    fun ready() = paparazzi.snap { ${CLASS}Content(${CLASS}UiState.Ready("$CLASS")) }

    @Test
    fun readyDark() = paparazzi.snap(dark = true) { ${CLASS}Content(${CLASS}UiState.Ready("$CLASS")) }
}
KT

cat > "$DIR/AGENTS.md" <<MD
# :feature:$NAME — AGENTS.md

TODO(agent): one sentence: what this vertical slice does for the user (link its task, T-xxx).

## Scope & Files

| File | Purpose |
|---|---|
| \`${CLASS}Navigation.kt\` | Public contract: \`${CLASS}Route\` + \`NavGraphBuilder.${NAME}Screen()\` |
| \`${CLASS}Screen.kt\` | \`${CLASS}Screen\` (stateful) → \`${CLASS}Content\` (stateless, screenshot-tested) |
| \`${CLASS}ViewModel.kt\` | \`${CLASS}UiState\`, \`${CLASS}ViewModel\` |
| \`${CLASS}ScreenshotTest.kt\` | Paparazzi: every distinct state, light + dark |

## Dependencies & Boundaries

- \`:core:model\`, \`:core:ui\` (+ \`:core:testing\` in tests) via \`convention.android.feature\`.
- **NEVER** depends on another feature. Needs data from one? Contract in \`:core:model\`.

## Verification

\`\`\`bash
./gradlew :feature:$NAME:testDebugUnitTest :feature:$NAME:verifyPaparazziDebug
./gradlew :feature:$NAME:recordPaparazziDebug   # only on intentional UI changes
\`\`\`
MD

grep -q "include(\":feature:$NAME\")" settings.gradle.kts || echo "include(\":feature:$NAME\")" >> settings.gradle.kts
if ! grep -q "project(\":feature:$NAME\")" app/build.gradle.kts; then
  perl -0pi -e "s|(// scripts/new-feature.sh adds new ones below this line.\n)|\$1    implementation(project(\":feature:$NAME\"))\n|" app/build.gradle.kts
fi

cat <<NEXT
Created :feature:$NAME.
Next:
  1. Fill the TODO in $DIR/AGENTS.md and add the module to the map in AGENTS.md.
  2. Wire it in app/.../AppNavigation.kt: import $PKG.${NAME}Screen, call ${NAME}Screen() in the NavHost.
  3. ./gradlew :feature:$NAME:recordPaparazziDebug   (first goldens; look at them)
  4. ./scripts/check-modular-boundaries.sh
NEXT
