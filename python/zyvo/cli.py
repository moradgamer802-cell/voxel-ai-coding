"""zyvo — command-line bootstrap for installing ZYVO from PyPI.

`pip install zyvo` gives you the `zyvo` command. Running it installs
the ZYVO layer (scripts + config + skills + installer) from the wheel's
own bundled copy — no network fetch for the layer — then hands over to
the real installer, which downloads the core engine with a single live
progress line.

Design: the pip package bundles the layer and acts as the launcher;
all real logic lives in install.sh, so curl-install and pip-install
behave identically (pip just skips the layer download).
"""

import argparse
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile

from . import __version__

# bundled layer lives inside the installed package (setuptools package-data)
_LAYER_SRC = os.path.join(os.path.dirname(__file__), "layer")
BOOT_DIR = os.path.join(os.path.expanduser("~"), ".local", "zyvo", "boot")


def _extract_layer(dest):
    """Copy the bundled layer into dest (keeps file modes via copytree)."""
    os.makedirs(dest, exist_ok=True)
    for entry in os.listdir(_LAYER_SRC):
        src = os.path.join(_LAYER_SRC, entry)
        shutil.copy2(src, dest, follow_symlinks=True) if os.path.isfile(src) else shutil.copytree(
            src, os.path.join(dest, entry), dirs_exist_ok=True
        )


def _jump_to_installer(boot):
    """Run the real installer with the boot layer as the layer source."""
    installer = os.path.join(boot, "install.sh")
    if not os.path.isfile(installer):
        sys.exit(
            "error: boot layer is incomplete (missing install.sh);\n"
            "       rerun:  zyvo install"
        )
    if not os.access(installer, os.X_OK):
        os.chmod(installer, 0o755)
    env = dict(os.environ, ZYVO_BOOT=boot)
    print("\nzyvo: layer ready — starting the core installer…\n")
    sys.exit(subprocess.call(["sh", installer], env=env))


def _configure_rc():
    """Make sure the shell rc points at the boot scripts dir."""
    rc = os.path.join(os.path.expanduser("~"), ".bashrc")
    if not os.path.exists(rc):
        return
    with open(rc, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    marker = "# ZYVO PATH"
    if marker in content:
        return
    boot_bin = os.path.join(BOOT_DIR, "scripts")
    with open(rc, "a", encoding="utf-8") as f:
        f.write('\n# ZYVO PATH\ncase ":$PATH:" in *":{}:"*) ;; *) export PATH="{}:$PATH";; esac\n'.format(
            boot_bin, boot_bin
        ))
    print("zyvo: added ZYVO PATH to {}".format(rc))


def cmd_install(args):
    if os.path.isfile(os.path.join(BOOT_DIR, "install.sh")):
        print("zyvo: layer already installed — starting the core installer…")
        _jump_to_installer(BOOT_DIR)
        return 0
    shutil.rmtree(BOOT_DIR, ignore_errors=True)
    print("zyvo: writing layer to {}".format(BOOT_DIR))
    _extract_layer(BOOT_DIR)
    _configure_rc()
    _jump_to_installer(BOOT_DIR)
    return 0


def cmd_uninstall(args):
    if os.path.isdir(BOOT_DIR):
        shutil.rmtree(BOOT_DIR)
        print("zyvo: removed layer {}".format(BOOT_DIR))
    else:
        print("zyvo: no layer found at {}".format(BOOT_DIR))
    print("zyvo: done — your projects and files were left untouched")
    return 0


def cmd_version(args):
    print("zyvo-bootstrap {}".format(__version__))
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="zyvo",
        description="Install ZYVO (AI coding CLI for Termux).",
    )
    sub = parser.add_subparsers(dest="command")
    sub.add_parser("install", help="install the ZYVO layer + core engine")
    sub.add_parser("uninstall", help="remove the downloaded layer only")
    sub.add_parser("version", help="print the bootstrap version")
    args = parser.parse_args(argv)

    if args.command == "uninstall":
        return cmd_uninstall(args)
    if args.command == "version":
        return cmd_version(args)
    # default (no command, or "install") → full install
    return cmd_install(args)


if __name__ == "__main__":
    sys.exit(main())