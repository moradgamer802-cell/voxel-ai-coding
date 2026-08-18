---
name: testing
description: Write and run tests — unit, integration, browser — verify code works, catch regressions. Use for any "make sure it works", "add tests", or before delivering a feature.
---

# Testing Skill

## Which test type (match the situation)
- **Unit** — one function/component in isolation. Fast, catch logic bugs
- **Integration** — a flow (API → DB → response). Catch wiring bugs
- **E2E / browser** — the real user path in a browser. Most realistic, slowest
- On a phone (Termux), prefer unit + integration tests that run on the CLI — real browsers are heavy

## Python (stdlib pytest-less alternative first)
```python
# test_math.py — run: python3 -m pytest test_math.py  (pkg install python-pytest?)
# or plain asserts with a tiny runner
def test_add():
    assert add(2, 3) == 5
```
- Simple pattern that always works without frameworks:
```python
def main():
    tests = [test_add, test_subtract]
    for t in tests:
        t()
        print(f"PASS {t.__name__}")
    print("all tests passed")
if __name__ == "__main__":
    main()
```

## JavaScript (Node)
```js
// test.js — run: node test.js (zero dependencies)
import { strict as assert } from 'node:assert';
import { add } from './math.js';
assert.equal(add(2, 3), 5);
console.log('all tests passed');
```
- For bigger projects: Vitest (`npm i -D vitest`, `npm test`) — fast, modern

## What makes a good test
- One behavior per test, descriptive name (`test_returns_empty_list_for_new_user`)
- Test the **edges**: empty input, max size, missing fields, wrong types
- Test the **failure path**: what happens when the API 500s, file is missing
- Avoid flaky tests: no real network/clock in unit tests — mock them
- Never test implementation details (private functions); test observable behavior

## Before writing tests
1. Read the function's requirements ("what should happen when X")
2. Write the test that fails first (red), then make it pass (green) — TDD when possible
3. Run the existing test suite — your change must not break it (regression check)

## When delivering code
- Run the tests and paste the results summary in the delivery message
- If a test needs real setup (DB, API key), put it behind a skip flag so the suite runs anywhere
- Tell the user the exact command to run tests themselves (`python3 test.py`, `npm test`)