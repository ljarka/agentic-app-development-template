# Agent skills

Skills are task-specific instructions an agent loads on demand (`SKILL.md` + optional references).
Claude Code finds them through `.claude/skills` (a symlink to this directory); other agents can
read them directly.

| Skill | Source | Use for |
|---|---|---|
| `bootstrap-app` | this template | requirements → app (`docs/BOOTSTRAP.md`) |
| `new-feature` | this template | adding a `:feature:<name>` module |
| `finish-task` | this template | Definition of Done for a task |
| `adaptive` | Google Android skills (Apache 2.0, `LICENSE.txt`) | phones/tablets/foldables, window sizes, multi-pane |
| `edge-to-edge` | Google Android skills (Apache 2.0, `LICENSE.txt`) | insets, system bars, IME |
| `jetpack-compose-performance` | Google Android skills (Apache 2.0, `LICENSE.txt`) | recomposition, stability, lazy lists |

`LICENSE.txt` applies to the three Google skills. Add more skills as directories here.
