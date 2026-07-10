
# mise + personal CLI baseline (mise-and-tools)

Installs mise (polyglot tool version manager) plus git, gh, Claude Code, and optionally zsh/starship. Persists Claude's login/history/memory across rebuilds via a named volume (assumes the 'vscode' remote user).

## Example Usage

```json
"features": {
    "ghcr.io/MartinSA04/devcontainer-base/mise-and-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installZsh | Install zsh and the starship prompt | boolean | true |
| installClaudeCode | Install the Claude Code CLI for the remote user | boolean | true |
| claudeCodeVersion | Claude Code version to install (stable, latest, or a pinned x.y.z) | string | stable |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/MartinSA04/devcontainer-base/blob/main/src/mise-and-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
