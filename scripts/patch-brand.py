#!/usr/bin/env python3
"""ZYVO brand patcher for the opencode binary.

Replaces user-visible "OpenCode" strings with "ZYVO" using exact byte
matches (same length, auto-padded with trailing spaces), so no offsets
are needed and missing strings are skipped per version. Functional
bytes (API keys, header names, protocol fields, system prompts) are
never touched.

Usage: patch-brand.py <input.bin> <output.bin>
"""

import sys

# (exact bytes to find, replacement "ZYVO" text) — replace ALL occurrences.
# New text is auto-padded with spaces to the old length.
PATCHES = [
    # core screens
    (b'setTerminalTitle("OpenCode")',     b'setTerminalTitle("ZYVO")'),
    (b'A(n,p,1,"OpenCode",a,void 0,O.BOLD)', b'A(n,p,1,"ZYVO",a,void 0,O.BOLD)'),
    (b'agentInfo:{name:"OpenCode"',        b'agentInfo:{name:"ZYVO"'),
    (b'<title>OpenCode</title>',           b'<title>ZYVO</title>'),
    # ask / permission texts
    (b'Tell OpenCode what to do differently',
     b'Tell ZYVO what to do differently'),
    (b'until OpenCode is restarted.',      b'until ZYVO is restarted.'),
    (b'will allow the following patterns until OpenCode is restarted',
     b'will allow the following patterns until ZYVO is restarted'),
    (b'This will allow the following patterns until OpenCode is restarted',
     b'This will allow the following patterns until ZYVO is restarted'),
    (b'OpenCode service failure',          b'ZYVO service failure'),
    (b'Request is not supported by this version of OpenCode Server (Server responded with text/html)',
     b'Request is not supported by this version of ZYVO Server (Server responded with text/html)'),
    # provider / model labels
    (b'name:"OpenCode Zen"',               b'name:"ZYVO Zen"'),
    (b'name:"OpenCode Go"',                b'name:"ZYVO Go"'),
    (b'name:"OpenCode Default"',           b'name:"ZYVO Default"'),
    (b'label:"OpenCode Login"',            b'label:"ZYVO Login"'),
    # upgrade / connect dialogs
    (b' and enable OpenCode Go',           b' and enable ZYVO Go'),
    (b'OpenCode Zen gives you access to all the best coding models at the cheapest prices with a single API key.',
     b'ZYVO Zen gives you access to all the best coding models at the cheapest prices with a single API key.'),
    (b'OpenCode Go is a $10 per month subscription that provides reliable access to popular open coding models with generous usage limits.',
     b'ZYVO Go is a $10 per month subscription that provides reliable access to popular open coding models with generous usage limits.'),
    (b'Subscribe to OpenCode Go for reliable access to the best open-source models, starting at $5/month.',
     b'Subscribe to ZYVO Go for reliable access to the best open-source models, starting at $5/month.'),
    # tips / menus
    (b'Use {highlight}/connect{/highlight} with OpenCode Zen for curated, tested models',
     b'Use {highlight}/connect{/highlight} with ZYVO Zen for curated, tested models'),
    (b'Run {highlight}opencode serve{/highlight} for headless API access to OpenCode',
     b'Run {highlight}opencode serve{/highlight} for headless API access to ZYVO'),
    (b'Create a plugin to prevent OpenCode from reading sensitive files',
     b'Create a plugin to prevent ZYVO from reading sensitive files'),
    (b'Uninstall OpenCode',                b'Uninstall ZYVO'),
    (b'description:"close OpenCode"',      b'description:"close ZYVO"'),
    (b'Thank you for using OpenCode!',     b'Thank you for using ZYVO!'),
    (b'Successfully updated to OpenCode v',
     b'Successfully updated to ZYVO v'),
]


def load(path):
    with open(path, "rb") as f:
        return bytearray(f.read())


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    buf = load(sys.argv[1])
    total = 0
    for old, new in PATCHES:
        if len(new) < len(old):
            new = new + b" " * (len(old) - len(new))
        assert len(old) == len(new), (old, len(old), len(new))
        if old not in buf:
            print(f"SKIP {old[:52]!r}")
            continue
        n = buf.count(old)
        buf = buf.replace(old, new)
        total += n
        print(f"OK x{n}  {old[:52]!r}")
    with open(sys.argv[2], "wb") as f:
        f.write(buf)
    print(f"patched {total} occurrences -> {sys.argv[2]}")


if __name__ == "__main__":
    main()