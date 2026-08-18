"""ZYVO — ready-to-use AI coding CLI (OpenCode) for Termux.

This pip package is a thin bootstrap: it downloads the ZYVO layer
(scripts + config + skills) from the GitHub repo, unpacks it, then
hands over to the real installer (scripts/install.sh) which does
everything else (core engine, deps, single-line live progress).
"""

__version__ = "0.1.0"