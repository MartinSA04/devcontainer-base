
# mise + persistent Claude Code (mise-claude)

A dev container preloaded with mise, git, gh, and Claude Code, where Claude's login session, history, and memory persist across container rebuilds via a named volume.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Base image variant (Microsoft dev container base images; all use the 'vscode' user) | string | ubuntu |
| installZsh | Install zsh and the starship prompt | boolean | true |
| claudeCodeVersion | Claude Code version to install (stable, latest, or a pinned x.y.z) | string | stable |



---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/MartinSA04/devcontainer-base/blob/main/templates/mise-claude/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
