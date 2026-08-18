---
description: Select a model tier — max / lightning / mid / ultra.
agent: build
---

The user will select a model tier. $ARGUMENTS

Steps:
1. If $ARGUMENTS contains a tier (e.g. "max", "lightning", "mid", "ultra"), run `oc-settings model <tier>` directly (run the menu if no tier is given).
2. If no tier is given, show the user the options:
   - Max (default, full-power, stable) → zyvo/deepseek-v4-flash-free
   - Lightning → zyvo/nemotron-3.5-lightning-free
   - Mid (balanced) → zyvo/mimo-v2.5-free
   - Nemotron Ultra → zyvo/nemotron-3-ultra-free [! provider errors reported — experimental]
   Run `oc-settings model <tier>` based on the user's choice.
3. After the config updates, tell the user to restart zyvo (the new model applies then).
4. Free model list: offer `oc-settings models` if the user wants to see it.
