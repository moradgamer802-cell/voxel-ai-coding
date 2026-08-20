#!/usr/bin/env python3
"""ZYVO brand patcher for the opencode binary.

Replaces user-visible "OpenCode" strings with "ZYVO" using exact byte
matches (same length, auto-padded with trailing spaces), so no offsets
are needed and missing strings are skipped per version. Functional
bytes (API keys, header names, protocol fields, system prompts) are
never touched.

Pixel-art rows use fit(): the replacement decodes to the same character
count (row width used by the layout code) and occupies the same byte
count (binary layout stays intact).

Usage:
  patch-brand.py <input.bin> <output.bin>          -- brand (OpenCode -> ZYVO)
  patch-brand.py <input.bin> <output.bin> --blank-logo  -- erase pixel-art
    logo rows (all-space rows, same width/bytes, layout unchanged)
"""

import sys

# pixel-art wordmark rows (escaped JS strings from the home screen art)
# -> design rows (decoded unicode). fit() re-encodes to exact length.
# Each entry: (raw "OPENCODE" bytes, previously-shipped "ZYVO" design,
# new big double-wide "ZYVO" design). Replacing both the raw form AND
# the previous design lets a fresh binary get the big logo directly and
# an already-branded binary (small ZYVO) upgrade in place.
LOGO = [
    # 8 glyphs "OPENCODE" -> 8 glyphs of double-wide "ZYVO": every row
    # fills the same width as the original wordmark (var O / var To)
    (b"\\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588 "
     b"\\u2588\\u2580\\u2580\\u2584 \\u2588\\u2580\\u2580\\u2580 \\u2588\\u2580\\u2580\\u2588 "
     b"\\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588",
     "█▀▀█ █  █ █  █ █▀▀█",
     "█▀▀▀▀▀▀▀ █      █ █      █ █▀▀▀▀▀▀█"),
    (b"\\u2588  \\u2588 \\u2588  \\u2588 \\u2588\\u2580\\u2580\\u2580 \\u2588  \\u2588 "
     b"\\u2588    \\u2588  \\u2588 \\u2588  \\u2588 \\u2588\\u2580\\u2580\\u2580",
     "  ▄▀ █▀▀█  ▀▀  █  █",
     "    ▀▀▀▀ █▀▀▀▀▀▀█  ▀    ▀  █      █"),
    (b"\\u2580\\u2580\\u2580\\u2580 \\u2588\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580 "
     b"\\u2580  \\u2580 \\u2580\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580 "
     b"\\u2580\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580",
     "▀▀▀▀   █    ▀  ▀▀▀▀",
     "▀▀▀▀▀▀▀▀    █       ▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀"),
]

# two-tone home-screen logo: left half (dim) "OPEN" -> "ZY",
# right half (bright) "CODE" -> "VO" (double-wide, fills the halves)
LOGO_TN = [
    # left rows -> Z Y (row 1..3)
    (b"\\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2584",
     "█▀▀█ █  █ █  █",
     "█▀▀▀▀▀▀▀ █      █"),
    (b"\\u2588__\\u2588 \\u2588__\\u2588 \\u2588^^^ \\u2588__\\u2588",
     "  ^▀ █^^█  ^▀ ",
     "    ▀▀▀▀ █^    ^█"),
    (b"\\u2580\\u2580\\u2580\\u2580 \\u2588\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580 \\u2580~~\\u2580",
     "▀▀▀▀   █    ▀ ",
     "▀▀▀▀▀▀▀▀    █    "),
    # right rows -> V O (row 1..3)
    (b"\\u2588\\u2580\\u2580\\u2580 \\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588 \\u2588\\u2580\\u2580\\u2588",
     "█▀▀█",
     "█      █ █▀▀▀▀▀▀█"),
    (b"\\u2588___ \\u2588__\\u2588 \\u2588__\\u2588 \\u2588^^^",
     "█  █",
     " ▀    ▀  █      █"),
    (b"\\u2580\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580 \\u2580\\u2580\\u2580\\u2580",
     "▀▀▀▀",
     "  ▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀"),
]

# (exact bytes to find, replacement "ZYVO" text) — replace ALL occurrences.
# New text is auto-padded with spaces to the old length (ASCII only).
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
    # TUI session list "Continue" hint:  opencode -s <id> -> zyvo -s <id>
    (b'opencode -s ${U.sessionID}',        b'zyvo -s ${U.sessionID}'),
]


def fit(old: bytes, design: str) -> bytes:
    """Length-safe replacement for an escaped pixel-art row.

    Old bytes are an escaped JS string. Returns a replacement that
    (a) decodes to the same number of characters (row width used by the
    layout code) and (b) occupies the same number of bytes (the rest of
    the binary stays byte-aligned). Non-ASCII glyphs must be escaped;
    extra escape slots are filled with escaped spaces.
    """
    esc = old.count(b"\\u")
    dec = esc + (len(old) - esc * 6)
    g = (len(old) - dec) // 5  # #escapes if the tail is all 1-byte chars
    l = dec - g
    assert g * 6 + l == len(old), (len(old), dec, g, l)
    assert len(design) <= dec, (design, dec)
    chars = list(design) + [" "] * (dec - len(design))
    need = [i for i, c in enumerate(chars) if ord(c) > 0x7F]
    assert len(need) <= g, (design, g, need)
    esc_idx = set(need)
    for i, c in enumerate(chars):
        if len(esc_idx) >= g:
            break
        if c == " " and i not in esc_idx:
            esc_idx.add(i)
    assert len(esc_idx) == g, (design, g, esc_idx)
    out = "".join("\\u%04x" % ord(chars[i]) if i in esc_idx else chars[i]
                  for i in range(len(chars)))
    out = out.encode()
    assert len(out) == len(old), (design, len(out), len(old))
    return out


def load(path):
    with open(path, "rb") as f:
        return bytearray(f.read())


def main():
    if len(sys.argv) not in (3, 4) or (len(sys.argv) == 4 and sys.argv[3] != "--blank-logo"):
        print(__doc__)
        sys.exit(1)
    buf = load(sys.argv[1])
    total = 0
    if len(sys.argv) == 4 and sys.argv[3] == "--blank-logo":
        # Erase the pixel-art logo: replace every art row (as currently
        # patched, or the raw unpatched form) with an all-space row of the
        # same decoded width and byte length. Layout stays intact.
        for old, prev, new in LOGO + LOGO_TN:
            cur = fit(old, new)
            prev = fit(old, prev)
            for src, dst in ((cur, fit(cur, "")), (prev, fit(prev, "")), (old, fit(old, ""))):
                if src not in buf:
                    continue
                n = buf.count(src)
                buf = buf.replace(src, dst)
                total += n
                print(f"BLANK x{n}  {src[:44]!r}")
        # accent/top strips of the home + help logo (p.right / O arrays)
        for row in (b"             \\u2584     ",
                    b"\\u2800                                \\u2584     "):
            if row not in buf:
                print(f"SKIP row {row[:30]!r}")
                continue
            n = buf.count(row)
            buf = buf.replace(row, fit(row, ""))
            total += n
            print(f"BLANK x{n}  {row[:30]!r}")
        # 4-glyph-shape sequences (p/t left/right arrays, bright "O" etc).
        # NOTE: do NOT touch the "_"/"^" rows of the logo font
        # ("\\u2588__\\u2588" / "\\u2588_^\\u2588"): editing those two
        # strings makes the standalone binary fall back to plain Bun CLI.
        sp = b"\\u0020"
        for g in (b"\\u2800",
                  b"\\u2588\\u2580\\u2580\\u2580",
                  b"\\u2588\\u2580\\u2580\\u2588",
                  b"\\u2580\\u2580\\u2580\\u2580"):
            if g not in buf:
                print(f"SKIP glyph {g!r}")
                continue
            n = buf.count(g)
            buf = buf.replace(g, sp * (len(g) // 6))
            total += n
            print(f"BLANK-G x{n} {g!r}")
        with open(sys.argv[2], "wb") as f:
            f.write(buf)
        print(f"blanked {total} logo rows -> {sys.argv[2]}")
        return
    for old, prev, new in LOGO + LOGO_TN:
        new = fit(old, new)
        prev = fit(old, prev)
        for src, dst in ((old, new), (prev, new)):
            if src not in buf:
                print(f"SKIP {src[:52]!r}")
                continue
            n = buf.count(src)
            buf = buf.replace(src, dst)
            total += n
            print(f"OK x{n}  {src[:52]!r}")
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