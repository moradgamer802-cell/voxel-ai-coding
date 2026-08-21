---
name: lets-scroll
description: >
  Build an immersive scroll-driven "fly through the world" landing page for any
  business or idea. As the visitor scrolls, a pre-rendered camera flies through
  3D scenes with NO cuts — one continuous journey. FREE BY DESIGN: the AI designs
  everything and writes a kit of copy-paste prompts (images + videos) into the
  project's lets-scroll/ folder with a step-by-step beginner guide; the user
  generates the assets in ANY AI tool they like (free tools work) and pastes the
  results next to the prompts. Then the AI verifies, encodes, and wires a
  portable scroll-scrub engine. Use when the user wants a "3D world" site, a
  scroll cinematic, a diorama landing, or to turn a business into a scrollable
  world. Paid render automation (Monid/Higgsfield CLIs) exists as an OPTIONAL
  appendix in references/pipeline.md for users who already have those tools.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Skill
---

# lets-scroll

Build a landing page where scrolling flies the visitor through a little 3D
world — scene after scene, no cuts — ending at the brand.

> **BEGINNER VOICE — mandatory for the whole skill.** The user may be a complete
> beginner on a phone. Short sentences. Simple words. Every technical term gets a
> one-line plain meaning the first time it appears. Never dump jargon; explain
> what to do, in order, like a friendly guide. All user-facing writing (chat,
> GUIDE.md, file names) uses the plain `image-…` / `video-…` vocabulary below —
> never internal words like "still", "dive", "connector", "leg".

## MANDATORY FLOW — no shortcuts, ever

**If this skill is loaded, you follow ALL of it, in order.** The flow is:
interview → design → write the kit (`lets-scroll/` with prompts + GUIDE.md) →
WAIT for the user's renders → verify → assemble → check together.

**You NEVER (these are the classic mistakes — do not make them):**
- build the site directly (writing index.html first, "to save time")
- skip the interview or the kit — the kit IS the deliverable of your design
- render or fake assets yourself — you cannot generate images/videos; the
  USER renders them in their own tools, always
- copy a user-supplied photo into the page as if it were a scene — a product
  photo is a REFERENCE, not a scene
- jump ahead to Step 4/5 before every kit file has its render

If you ever feel like shortcutting: stop, re-read this block, and write the kit.

**If the user gives you a picture (e.g. their product photo):**
1. Look at it first with `boomcode-vision` — describe it in detail (shape,
   colors, materials, text/logo on it).
2. That description goes INTO your prompts: every scene that features the
   product must describe the SAME product so the generated world matches it.
3. The photo itself stays as a reference — it does not replace any kit file
   and does not skip any step.
4. Then continue the normal flow (a short interview is still needed: camera
   style, scene count, phone version).

## The idea in one minute

1. You interview the user about their business/idea (simple questions).
2. You design the scenes and the camera journey.
3. You write a **kit** into the project — one folder, `lets-scroll/`:
   - `GUIDE.md` — a friendly step-by-step guide for the user
   - one prompt file per picture (`image-01-….txt`) and per video clip
     (`video-01-….txt`, `video-connector-1.txt`)
4. The user copies each prompt into ANY AI image/video tool (free ones are fine),
   downloads the result, and saves it **in the same folder, same name**:
   `image-01-….txt` → `image-01-….png`, `video-01-….txt` → `video-01-….mp4`.
5. When they say "done", you verify every file, polish it with ffmpeg, wire the
   scroll engine, open it with `boomcode preview`, and check it together.

The kit is the contract. The folder tells everyone (you and the user) exactly
what exists, what is waiting, and what is still missing.

## Step 0 — Quick check (10 seconds)

You need only **ffmpeg + ffprobe** on this path. Check `ffmpeg -version` and
`ffprobe -version`. If missing or broken:

- **Termux (Android):** `pkg install ffmpeg` (or `pkg reinstall ffmpeg` if a
  broken install reports linker errors). Also `pkg install python` if python is
  missing (needed later for the local preview server).
- Everything else — image/video generation — happens in the USER's tools, so
  nothing else is required from this machine.
- Scratch files go to `$TMPDIR` (never `/tmp` — Termux has no `/tmp`).

Optional: if the user already pays for render CLIs, automation lives in
`references/pipeline.md`. Do not bring it up unless they ask.

## Step 1 — Interview (simple questions, one at a time)

Ask these in plain words. Accept answers in any language. Record the answers
(the checklist in `references/prompts.md` is your write-down format).

1. **What is this about?** (their business/idea — open question, never
   multiple-choice)
2. **Brand kit** — name + a few brand colors if they have them (or offer to
   propose a palette). Keep it to: name, 4–6 colors, tone.
3. **Look & feel** — show the options by feel, one line each (default: **clay
   diorama**; alternates in `references/prompts.md`: papercraft, glossy toy,
   claymation, neon night, photoreal). One choice for the whole site.
4. **Site type** — what kind of journey? Show these picks, one line each:
   - **Business tour** — walk through the shop/kitchen/office like a visitor
   - **Product showcase / review** — the camera circles and closes in on ONE
     product from all sides, close-up details, like a video review
   - **Story journey** — how it's made / farm-to-table / idea-to-launch
   - **Portfolio / gallery** — one beautiful vignette per work or project
   The pick shapes the scene list (a product showcase builds every scene
   around the same product; a tour builds one scene per place, etc.).
5. **Camera style** — ask by feel, one line each:
   - **Walkthrough** — the camera walks through the world like a visitor
     (architecture **A** — one continuous forward take; simplest, recommended)
   - **Fly-through** — the camera dives down into the world from above
     (architecture **B** — dive + linking clips)
   - **Orbit showcase** — for product review: the camera circles the product,
     sweeps around it and pushes in on details (A with orbit moves from
     `references/prompts.md` mid-leg move library)
   - **Postcard view** — a fixed, postcard-pretty angle on every scene,
     almost no camera movement (A with the locked-iso clause)
6. **How many scenes?** Offer 2 / 4 / 6 (6 is the max that stays smooth).
   Then propose the scene list from their answer to #1 — each scene gets a
   subject, a short headline idea, one-line body, 0–3 tags; the last scene is
   the hero + call-to-action. Confirm the list with the user.
7. **Phone version?** ("should the site also have a vertical version for
   phones?") — if yes, the kit doubles the video prompts (a 9:16 copy of each)
   — say plainly that it's about twice the generating work for them.

## Step 2 — Write the kit into the project

Create ONE folder in the project root:

```
lets-scroll/
├── GUIDE.md                             ← the friendly how-to (project root level)
└── prompts/                             ← THE prompt folder — prompts AND outputs live here
    ├── image-01-<short-scene-name>.txt  ← picture prompt
    │   image-01-<short-scene-name>.png  ← user saves the result HERE, same name
    ├── image-02-<name>.txt
    │   image-02-<name>.png
    ├── video-01-<what-it-does>.txt      ← video prompt
    │   video-01-<what-it-does>.mp4
    └── video-connector-1.txt            ← only for architecture B
        video-connector-1.mp4
```

**Naming rules (this is the whole system):**
- `image-…` = it makes a PICTURE. `video-…` = it makes a VIDEO CLIP.
- The number is the order to generate in.
- The prompt file `X.txt` and the user's saved result `X.png` / `X.mp4` share
  the exact same name and live in the exact same folder.
- Architecture A: `image-01…` to `image-N` (one per scene) and `video-01…` to
  `video-N` (one journey clip per scene).
- Architecture B: the same images, but videos are `video-01…` (dive into each
  scene) plus `video-connector-1…` (the linking flight between scenes).

**STRONG PROMPT RULES — every prompt must be rich, specific, and self-contained.**
A weak prompt gives a generic result and breaks the world's cohesion. Every
prompt you write must include ALL of:
- **Subject in detail** — what exactly is in the scene, named and described
  (materials, colors, props, tiny details that make it feel real)
- **Environment** — surroundings, ground, sky, background depth cues
- **Lighting** — direction, warmth, time of day, mood of the light
- **Camera** — angle, height, lens feel (for videos: the exact movement,
  speed, and "no camera shake / no cuts / smooth" clauses)
- **Style block** — the full style preamble from `references/prompts.md`
  baked in verbatim (never "same style as before" — every file works alone)
- **Negatives** — "no text, no watermark, no logo, no people unless asked,
  no motion blur"
One prompt = one full paragraph of specifics. If a prompt could describe a
hundred different scenes, it is too weak — rewrite it.

**Every prompt file starts with a marker line, then the full prompt:**

```
=== IMAGE PROMPT (generates 1 picture) ===
…complete prompt, self-contained (style preamble baked in from references/prompts.md)…

SAVE AS: image-01-shopfront.png   (3:2 landscape, at least 1536px wide,
solid background, no text in the picture)
```

```
=== VIDEO PROMPT (generates 1 short clip) ===
…complete prompt…
FIRST FRAME: attach video-01-start.png (provided next to this prompt) —
your tool must support a start/first frame.
SAVE AS: video-01-shopfront.mp4   (16:9, ~8 seconds, no sound)
```

Use the templates in `references/prompts.md` (scene still, leg/dive, connector)
— they bake in the style preamble so every prompt works alone in any tool.

**Start frames (architecture A chain):** the journey must be seamless, so
video-02 continues from the LAST frame of video-01. Do it step by step:
1. Write all image prompts + the FIRST video prompt now.
2. When `video-01….mp4` arrives, extract its last frame:
   `ffmpeg -sseof -0.1 -i video-01-x.mp4 -frames:v 1 video-02-start.png`
3. Write/update `video-02….txt` to attach that frame, and tell the user.
(For architecture B, connectors get BOTH a first and a last frame — extract
them from the two videos they link.)

**GUIDE.md** — write it for a total beginner, roughly:

```markdown
# Your 3D website — how to finish it

Each .txt file here is one prompt. Generate them in number order (01, 02, …).

- image-… files make PICTURES → paste into any AI image tool
- video-… files make SHORT VIDEOS → paste into any AI video tool
  (it must accept a start/first frame — the file is already in this folder)

For every prompt: open it, copy everything under the === line, run it in your
tool, download the result, and save it in THIS folder with the exact name from
the "SAVE AS" line (image-01-shopfront.png, video-01-shopfront.mp4, …).

The videos connect like a chain — that's why the order matters. If a video
prompt says "FIRST FRAME: attach …", upload that frame together with the prompt.

When everything has its file next to its prompt, tell the AI: **done**.
If a result looks wrong, just delete that file and try again.
```

**Also show the user a simple status table in chat** (never a wall of prose):

| # | file to make | kind | needs start frame? | status |
|---|---|---|---|---|
| 1 | image-01-shopfront.png | picture | — | waiting |

Keep it updated as files arrive.

## Step 3 — As files arrive: check them kindly

After the user says files are in (or anytime they say "check"):

1. `ls lets-scroll/` — match every `X.txt` to its `X.png`/`X.mp4`.
2. Verify each new file before relying on it:
   - pictures: opens, 3:2 landscape, ≥ ~1536px wide (`ffprobe` or PIL)
   - videos: plays, 16:9 (or 9:16 mobile), duration ≈ 8s (dives) / 5s
     (connectors), **frame 0 must match the start frame** you handed over —
     extract frame 0 with ffmpeg and compare by composition (or
     `boomcode-vision` on both). A video whose tool ignored the start frame
     will break its seam — ask for a re-run of that one prompt.
3. Update the status table and tell the user in one friendly line what's left.
4. Architecture A: extract each accepted video's last frame and unlock the
   next video prompt (Step 2 chain rule).

Never scold a bad file — just say which number to re-run and why in one line.

## Step 4 — Assemble (once every file is accepted)

1. **Optional floating scenes** (only if the style wants it, e.g. product
   close-ups floating beside the world): strip the background with
   `references/knockout.py` (needs PIL — `pkg install python pillow` /
   `pip install pillow`).
2. **Encode for smooth scrolling** — scrubbing means the page sets
   `video.currentTime` as you scroll, so clips must be encoded kindly:

   ```bash
   ffmpeg -i src.mp4 -an -vf "unsharp=5:5:0.8:5:5:0.0" \
     -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p \
     -g 8 -keyint_min 8 -sc_threshold 0 -movflags +faststart out.mp4
   ```

   Native resolution, no downscale. If the user opted into the phone version,
   also make each clip a 9:16 native portrait copy encoded 720 wide with
   `-g 4`, crf 23 (cheaper seeks on phone decoders), plus each portrait clip's
   first frame as the phone poster image.
3. **Place files** (project root, served by the page):
   - `assets/<scene>.webp` — the stills (`cwebp -q 84`, resize to 1800)
   - `assets/vid/<scene>.mp4` + `-m.mp4` portrait copies + connector clips
4. **Wire the engine** — copy `references/scrub-engine.js` and
   `references/index-template.html` into the project and fill the
   `mountLetsScroll(config)` block: `brand`, `diveScroll: 1.3`,
   `connScroll: 0.9`, one `sections[]` entry per scene
   (`id, label, still, clip, clipMobile, stillMobile, scroll, linger, accent,
   eyebrow, title, body, tags, cta`), `connectors[]` for architecture B
   (architecture A: `connectors: []` and a small crossfade ~0.08).
   Copy rules (eyebrow/title/body/tags) are in `references/prompts.md`.

## Step 5 — See it and check it (phone-friendly QA)

There is no headless browser here — check it the human way:

1. `boomcode preview` — opens the page in the phone/desktop browser.
2. Scroll through slowly, then fast. Ask the user to look for one thing:
   **does any scene "jump" or flash at a boundary?** (a jump = the video's
   first frame didn't match — re-check that pair's start frame; a flash = the
   crossfade band is too short).
3. Verify the technical parts from the shell:
   - file specs re-run through `ffprobe` (aspect, duration)
   - first-frame matching via ffmpeg extract + `boomcode-vision` comparison
   - page loads over the preview server (no `file://` — browsers block it;
     that's why `boomcode preview` exists)
4. Phone version (if built): open the same link on the phone — portrait clips
   must be served there (natively portrait, not squashed), posters must match
   each clip's first frame, scrolling with the URL-bar collapsing must not
   jump the page, and reduced-motion users should see the stills, no videos.
5. Fix round: adjust `crossfade`/`linger`, re-encode a clip, or ask for one
   re-run — then check again. Only ship when the user says it feels smooth.

## Gotchas (hard-won, the free-path subset)

- **Start frames are sacred.** A tool that ignores the attached first frame
  will break every seam after it. Verify frame 0 on arrival, every time.
- **Architecture A is a chain.** Video 2 starts from video 1's actual last
  frame — never from the original image. Extract, don't assume.
- **No `file://` previewing** — browsers block the scripts and blob fetching
  the engine needs. Always `boomcode preview`.
- **Blob loading is why scrubbing works** — the engine fetches clips as blobs
  (fully seekable) so plain static serving is fine; don't switch to
  byte-range hacks.
- **Never downscale the masters** — encode at native resolution, crf ~20,
  small GOP (`-g 8`; portrait 720-wide `-g 4`).
- **ffmpeg on Termux** can arrive broken (linker errors) — `pkg reinstall
  ffmpeg` fixes it; check before blaming the videos.
- **Six scenes is the ceiling** — more scenes = more seams = harder to keep
  smooth.
- iOS Safari is the strictest judge: if the priming/poster logic is touched,
  test that the first scene paints instantly with no black flash.

## References

- `references/prompts.md` — intake checklist + style preambles + all prompt
  templates (scene picture, journey video, connector video) + copy rules
- `references/pipeline.md` — OPTIONAL paid automation (Monid/Higgsfield CLIs)
  and the full encode/asset recipes (§6/§6b) for users who have those tools
- `references/scrub-engine.js` — the scroll engine (zero dependencies)
- `references/index-template.html` — the page template with the config block
- `references/knockout.py` — optional background removal for floating scenes
