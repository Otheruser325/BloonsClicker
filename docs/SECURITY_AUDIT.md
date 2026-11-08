# Security audit — Bloons Clicker

**Scope:** the static client-side game (`index.html`, `gc2.js`, `lib/`, language
packs). **Date:** 2026-11-08. **Release status:** passed for **v1.3.3**.

## Threat model

Bloons Clicker is a single-page, entirely client-side game. There is no backend,
no login, no account data, no payments and no telemetry; the only data the app
stores is the player's own save in `localStorage` (`gc2.savefile`). The only
attacker-controlled inputs are therefore:

1. the save string (edited in devtools, imported from storage, or handed to the
   console helper), and
2. third-party code that could run in the page (the app loads none).

A player can already edit their own save and their own JS console, so save
tampering is **cheating, not privilege escalation**. The security goal is that
malformed input can never execute code, exfiltrate data, or make the app hang
or crash persistently.

## Findings

| # | Severity | Finding | Status |
|---|---|---|---|
| 1 | High (availability) | Eternal Bloon rewards were summed with a per-stage loop; a crafted `eternal_stage` could freeze the tab on load/win. | **Fixed** — stage bounded to 999 on import and rewards summed in closed form. |
| 2 | High (availability) | `bloon.gain_exp` refreshed the whole HUD once per level with no practical per-call bound; a huge EXP grant or inflated cap could stall the tab. | **Fixed** — level-ups are batched, the HUD refreshes once, and the loop is capped per call (level 999 ceiling). |
| 3 | High | Save fields were admitted without finite/range validation; an overflowed count could turn the balance into NaN and make every purchase free, then re-save the corruption forever. | **Fixed in v1.3.1** — `MAX_VALUE`/`clamp_value`, finite range clamps, compensated summation rejects non-finite terms. |
| 4 | High | The save codec read the binary-field length header as half its real size, so saves with long set-bit runs decoded to garbage; an unparseable save also used to delete the player's progress. | **Fixed in v1.3.1** — nibble-length correction, byte-exact round-trip, oversized base64 rejected, bad saves quarantined under `gc2.savefile.corrupt` instead of wiped. |
| 5 | Medium | `localStorage` reads (startup load, corrupt-save quarantine) were unguarded; blocked storage/private mode/quota could throw during boot or the quarantine path. | **Fixed** — `storage_get/set/remove` helpers catch, warn once, and degrade to in-memory play. |
| 6 | Medium | No CSP and no Subresource Integrity on the vendored libraries. | **Fixed in v1.3.1** — strict CSP plus `sha384` SRI on vendored `lib/` scripts. |
| 7 | Low | Vendored jQuery 2.1.1 has public CVEs: CVE-2020-11022/11023 (`htmlPrefilter` XSS), CVE-2019-11358 (`$.extend` prototype pollution), CVE-2015-9251 (cross-domain AJAX). | **Accepted, upgrade recommended** — none of the vulnerable paths are reachable (see below). |
| 8 | Low | `touche.min.js` monkey-patches `jQuery.fn.on` globally and rewrites `click` bindings to `touchend` on touch-capable browsers. Not a vulnerability, but an event-semantics and update hazard. | **Accepted** — worked around with namespaced `click.gc2input` bindings. |
| 9 | Low | A prestige re-locks every upgrade but left the old shop tile visible with a stale tooltip. | **Fixed** — locked tiles are hidden until they unlock again. |
| 10 | Info | Clickjacking is technically possible. There is nothing to steal or click through (no auth, no payments). GitHub Pages cannot set headers; `frame-ancestors` is ignored in `<meta>`. | **Accepted** (low risk). |

## Save and runtime bounds

* `MAX_VALUE` = 1e308 for all game numbers; `Infinity`/`NaN` are clamped
  before entering the simulation.
* Generator counts clamp to `MAX_GENERATOR_COUNT` (1e21) and levels to
  999,999; Bloon level to 999; Eternal Bloon stage to 999; EXP to 1e15.
* A tick applies at most 5 minutes; offline progress at most 24 hours.
* A save is only written through `save_to_local_storage`; a second tab that
  sees another tab's save pauses autosave (`save_conflict`) instead of
  overwriting it.
* Compensated (Neumaier) summation keeps currency precise past 2^53.

## HTML sinks (XSS surface)

Every place that writes HTML was reviewed. All `.html()`/`.append()` arguments
are built from static game data (generator/item names, language-pack strings,
numbers formatted by `reprnum`) or the fixed battle-bloon list; no save-derived
string is ever interpolated into markup.

| Sink | Source of data | Safe? |
|---|---|---|
| `output.coffee` item/generator tiles & tooltips | `item.name`, `langs[lang]`, `reprnum(...)` — static packs | Yes |
| `output.coffee` `set_hud` / `set_hud_attr` | numbers and language strings | Yes |
| `input.coffee` generator pane | static generator definitions | Yes |
| `battle.coffee` status/target/HP/trophy text | static bloon names + numbers | Yes |
| `changelog.coffee` | static entries, rendered with `.text()` | Yes |
| `plus_marker.coffee` | formatted click gain | Yes |

The importer converts every save field to a finite number, clamps ranges, and
never stores a save-derived string in the DOM. Strings read from `localStorage`
are base-N decoded first; invalid characters throw inside `try/catch` and the
bad save is quarantined.

## Content-Security-Policy and SRI

`index.html` carries:

```
default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';
img-src 'self' data:; media-src 'self'; font-src 'self'; connect-src 'none';
object-src 'none'; base-uri 'none'; form-action 'none';
frame-ancestors 'none'
```

* `script-src 'self'` with SRI `sha384` hashes on the vendored libraries —
  injected or tampered scripts are blocked.
* `connect-src 'none'` — no fetch/XHR/WebSocket/beacon, so there is no network
  exfiltration channel.
* `img-src`/`media-src` allow `self`; bloon fallbacks are `data:` SVGs, which
  are still allowed for images.
* `object-src 'none'`, `base-uri 'none'`, `form-action 'none'` — plugin,
  `<base>`, and form-submission vectors are closed.
* `frame-ancestors 'none'` is ignored in a meta tag; it is retained for a
  future header-based deployment.

When a file in `lib/` changes, its SRI hash must be recomputed (see
`AGENTS.md`). Release pages append `?v=1.3.3` to local asset URLs, so a browser
cannot validate a new SRI hash against a stale cached library.

## Why the old jQuery is not exploitable here

* CVE-2020-11022/11023 require untrusted HTML passed to `.html()`/`.append()`.
  All such calls use static strings; no user input is treated as HTML.
* CVE-2019-11358 requires `$.extend(true, target, untrustedObject)`; the game
  does not call `$.extend` with untrusted data.
* CVE-2015-9251 requires cross-domain `$.ajax`/`$.getScript`; the game performs
  no AJAX and loads no remote resources (CSP also blocks it).

Upgrading to jQuery 3.7.x remains a defence-in-depth recommendation, but qtip,
nanoscroller and touche integrate with jQuery 2-era APIs and need regression
testing first.

## Verification

* `./compile` and `node --check gc2.js` after every source change.
* jsdom regression suite: normal startup; startup with throwing
  `localStorage`; save/load round-trip; corrupt-save quarantine; closed-form
  eternal rewards vs. the old loop; 999-stage clamp; batched huge-EXP
  level-up; hidden locked tiles after prestige; 0 HP display; release
  metadata; CSP and SRI; recalc after load/purchase returns finite GPS.
* Real Chromium load through the preview origin: all scripts, styles and
  images loaded (200), no CSP violations, game loop running.

## Residual risk / recommendations

1. Upgrade jQuery to 3.7.x (and re-test qtip/nanoscroller/touche) when time
   permits; keep it vendored and SRI-hashed.
2. Serve CSP as a response header if hosting ever allows it, including
   `frame-ancestors 'none'` (GitHub Pages cannot).
3. Keep the `storage`-event multi-tab guard covered by tests; it is the only
   cross-tab state path.
4. Treat `lib/` updates as a security review event: re-hash for SRI and re-run
   the import/CSP regression suite.
