# Publishing BOOMCODE to the Termux User Repository (TUR)

This guide takes the BOOMCODE Termux package from "works on my phone" to
`pkg install boomcode` for everyone.

- **Where:** https://github.com/termux-user-repository/tur
- **What:** a community-maintained package repository for Termux.
  Any developer can submit a package via pull request; the TUR
  maintainers review and merge it. Once merged, users enable the
  repo and run `pkg install boomcode`.
- **Time:** usually days to weeks (external review — outside our control).

## 1. Understand the layout

The Termux package layout is exactly what `install.sh` already produces
for a Termux install (`$PREFIX` = `/data/data/com.termux/files/usr`):

| Path                     | Content                                  |
|--------------------------|------------------------------------------|
| `$PREFIX/bin/boomcode`       | wrapper launcher (`scripts/boomcode`)        |
| `$PREFIX/libexec/opencode/opencode.bin` | the core engine binary |
| `$PREFIX/libexec/opencode/boomcode-core-version` | core version stamp |
| `$PREFIX/lib/libtagfix.so` (+ other libs) | native libraries     |
| `$HOME/.config/opencode/` | config, agents, commands, skills (user data — NOT packaged) |

Because the package only ships the wrapper + binary + libs (config is
user-level and already written by the installer), no script changes are
needed for TUR.

## 2. Build the package (test locally first)

Clone the TUR repo and add a package:

```bash
git clone --depth 1 https://github.com/termux-user-repository/tur.git
cd tur
mkdir -p packages/boomcode
```

Create `packages/boomcode/build.sh`:

```bash
TERMUX_PKG_HOMEPAGE=https://github.com/zyvo9/boomcode
TERMUX_PKG_DESCRIPTION="BOOMCODE - ready-to-use AI coding CLI (OpenCode) for Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@zyvo9"
TERMUX_PKG_VERSION=0.2.1
TERMUX_PKG_SRCURL=https://github.com/zyvo9/boomcode/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=false

termux_step_make_install() {
    # wrapper launcher
    install -Dm755 scripts/boomcode "${TERMUX_PREFIX}/bin/boomcode"
    install -Dm755 scripts/boomcode-menu "${TERMUX_PREFIX}/bin/boomcode-menu"
    install -Dm755 scripts/boomcode-uninstall "${TERMUX_PREFIX}/bin/boomcode-uninstall"
    install -Dm755 scripts/oc-settings.sh "${TERMUX_PREFIX}/bin/oc-settings"

    # core engine + version stamp (download at build time from the
    # guysoft/opencode-termux release so the package tracks it)
    local CORE_VERSION=0.2.1
    local CORE_URL="https://github.com/guysoft/opencode-termux/releases/download/v${CORE_VERSION}/opencode-1.17.9-android-aarch64.zip"
    curl -fsSL -o core.zip "$CORE_URL"
    unzip -oq core.zip
    install -Dm755 opencode.bin "${TERMUX_PREFIX}/libexec/opencode/opencode.bin"
    echo "${CORE_VERSION}" > boomcode-core-version
    install -Dm644 boomcode-core-version "${TERMUX_PREFIX}/libexec/opencode/boomcode-core-version"
    for lib in libtagfix.so libopentui.so libc++_shared.so librust_pty_arm64.so; do
        [ -f "$lib" ] && install -Dm644 "$lib" "${TERMUX_PREFIX}/lib/$lib"
    done
}
```

> Note: the `TERMUX_PKG_SRCURL` assumes the repo is tagged `v0.2.1`;
> add the tag when first publishing. The exact core URL/version must
> match the current `guysoft/opencode-termux` release — read it from
> install.sh before packaging.

Test the build locally (requires Docker, works on any OS):

```bash
docker compose run --rm builder ./build-package.sh boomcode
```

Fix any errors, repeat until the .deb builds cleanly.

## 3. Submit the pull request

1. Fork `termux-user-repository/tur` on GitHub.
2. Create a branch: `git checkout -b boomcode-package`
3. Commit `packages/boomcode/` (build.sh + any patches).
4. Push to your fork, open a PR against `termux-user-repository/tur`.
5. In the PR description, mention it's a first-time submission for the
   package, and that it builds aarch64 (and rename the PR title to
   `boomcode: add package`).

## 4. After merge — users install with

```bash
pkg install tur-repo        # one-time: enable the TUR repo
pkg update
pkg install boomcode
boomcode                        # first run completes the config automatically
```

Note that `boomcode` still uses the `OPENCODE_API_KEY` from the shell rc
(the built-in zero-config key), so it works immediately after install.

## Troubleshooting

- **`.build-package.sh` errors** — check TUR's README; the builder
  container must be pulled first (`docker compose build`).
- **Core URL changed** — the `guysoft/opencode-termux` release may update;
  bump `CORE_VERSION`/URL in build.sh to match the latest release.
- **Reviewer requests changes** — usually signing of the package or
  version pins; address them in the PR thread.