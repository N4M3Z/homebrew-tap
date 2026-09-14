# N4M3Z Homebrew Tap

> Activate this repository's commit and push checks after cloning.

I want you to finish setting up homebrew-tap. Execute all the steps below autonomously.

## OBJECTIVE

Hooks active (git `core.hooksPath` plus the jj `push` alias when the repo is colocated) and the toolchain for this repo installed.

## DONE WHEN

`make validate` exits 0, and `git config core.hooksPath` prints `.githooks`.

## TODO

- [ ] Run `make install`
- [ ] Confirm the repository check tools are available
- [ ] Run `make validate` and confirm it exits 0

## Steps

```sh
set -e
make install
export PATH="$HOME/.local/bin:$PATH"
missing=false
for tool in prek gitleaks shellcheck copier ruff semgrep mdschema; do
    if ! command -v "$tool"; then
        printf 'missing tool: %s\n' "$tool" >&2
        missing=true
    fi
done
[ "$missing" = false ]
make validate
```

`make install` supports macOS with Homebrew and Linux with Homebrew, apt, dnf, or pacman. It installs the repository check tools, verifies downloaded release archives against their upstream checksum manifests, and activates the git and jj hooks. Copier is used for template updates; mdschema supplies strict Markdown structure validation.

EXECUTE NOW: Complete the above TODO list to achieve: hooks wired and `make validate` green.
