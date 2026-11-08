# Security audit — Bloons Clicker

**Scope:** the static client-side game (`index.html`, `gc2.js`, `lib/`, language
packs). **Date:** 2026-11-08. **Release status:** passed for **v1.3.1**.

## Threat model

Bloons Clicker is a single-page, entirely client-side game. There is no backend,
no login, no account data, no payments and no telemetry; the only data the app
stores is the player's own save in `localStorage` (`gc2.savefile`). The only
attacker-controlled inputs are therefore:

1. the save string (edited in devtools or imported from storage), and
2. third-party code that could run in the page (the app loads none).

Since a player can already edit their own save and their own JS console, save
tampering is **cheating, not a privilege escalation**. The relevant security
goal is that malformed input can never execute code, exfiltrate data, or make
the app hang or crash persistently.

## Findings

| # | Severity | Finding | Status |
|---|---|---|---|
| 1 | High (availability) | `battle.recalculate_rewards` summed eternal rewards in a `for` loop up to `eternal_stage`; a hand-edited save with `eternal_stage = 1e9` froze the tab on every load/win. | **Fixed** — arithmetic series in closed form, stage clamped to 10,000 on load. |
| 2 | Medium | Every `localStorage` access was unguarded. Blocked storage (private mode, blocked cookies, sandboxed iframe, `file://` quirks) or a full quota threw during startup and on every 10 s autosave; progress was silently lost and the console spammed forever. | **Fixed** — `storage_get/set/remove` helpers catch, warn once and degrade to in-memory play. |
| 3 | Medium | No Content-Security-Policy. Any future injected script or accidentally added remote dependency would run with full page privileges. | **Fixed** — restrictive CSP meta tag (see below). |
| 4 | Low | Vendored jQuery 2.1.1 has public CVEs: CVE-2020-11022/11023 (`htmlPrefilter` XSS), CVE-2019-11358 (`$.extend` prototype pollution), CVE-2015-9251 (cross-domain AJAX). | **Accepted, upgrade recommended** — none of the vulnerable paths are reachable in this app (see below). |
| 5 | Low | `touche.min.js` monkey-patches `jQuery.fn.on` globally and rewrites all `click` bindings to `touchend` on touch-capable browsers. Not a vulnerability, but it silently changes event semantics for every library on the page and is an update hazard. | **Accepted** — worked around with a namespaced `click.gc2input` binding. |
| 6 | Info | Clickjacking: the game can be framed by another site. There is nothing to steal or click through (no auth, no payments), so impact is cosmetic. GitHub Pages cannot set response headers and `frame-ancestors` is ignored in `<meta>`. | **Accepted** (low risk). |
| 7 | High (availability) | `bloon.gain_exp` ran `recalc_gpc()` + `update_all_numbers()` once per level with no per-call bound; a save with a huge EXP grant or inflated level cap could freeze the tab. | **Fixed** — level-ups are batched, the HUD refreshes once, and the loop is capped per call. |

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

The save importer (`loadsave.coffee`) converts every field to a finite number,
clamps ranges, and never stores a save-derived string in the DOM. Strings read
from `localStorage` are base-N decoded first and any invalid character throws
inside `try/catch` (the corrupted save is then removed).

## Content-Security-Policy

`index.html` now sends:

```
default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';
img-src 'self' data:; media-src 'self' data:; font-src 'self';
connect-src 'self'; object-src 'none'; base-uri 'self'; form-action 'none'
```

* `script-src 'self'` — all game code is local; there are no inline scripts or
  `on*=` handlers. This blocks injected inline script and remote script.
* `img-src`/`media-src` allow `data:` because bloon SVGs and audio fallbacks are
  generated as data URIs.
* `style-src` keeps `'unsafe-inline'` because the UI uses `style=` attributes;
  stylesheet injection alone is not script execution.
* `connect-src 'self'` — the game makes no network requests, so remote
  fetch/XHR (a common exfiltration channel) is blocked.
* `object-src 'none'`, `base-uri 'self'`, `form-action 'none'` — plug legacy
  plugin, `<base>` and form-submission vectors.

## Why the old jQuery is not exploitable here

* CVE-2020-11022/11023 require untrusted HTML passed to `.html()`/`.append()`.
  All such calls use static strings; no user input is ever treated as HTML.
* CVE-2019-11358 requires `$.extend(true, target, untrustedObject)`; the game
  does not call `$.extend` at all.
* CVE-2015-9251 requires cross-domain `$.ajax`/`$.getScript`; the game performs
  no AJAX and loads no remote resources.

Upgrading to jQuery 3.7.x is still recommended as defence in depth, but qtip
2.x, nanoscroller 2.x and touche integrate with jQuery 2-era APIs and must be
regression-tested first; jQuery 3 removes `$.browser`, changes `$.parseJSON`
and alters `jQuery.fn.load` behaviour. Do not bump it unreviewed.

## Other observations

* **No secrets/PII.** Saves contain game state only. The QR export is rendered
  locally on a canvas; the save string is not sent anywhere.
* **No cookies, no analytics, no CDN.** All scripts, styles and images are
  vendored; `asset_url` prepends `img/` and never builds a remote URL from save
  data.
* **Multi-tab:** autosave is last-writer-wins every 10 s. Two open tabs can
  overwrite each other's progress. This is a data-integrity/UX issue, not a
  security issue; a `storage`-event guard would be the fix if desired.
* **`file://` origin:** `localStorage` may be unavailable or shared per-file
  depending on the browser; the guarded helpers keep the game playable.
* **Dynamic code evaluation:** the game never calls `eval`. jQuery's
  `globalEval` helper (which uses `eval`) is only reachable through
  `$.getScript` or HTML insertion containing script tags — the game does
  neither and accepts no untrusted HTML, so CSP `script-src 'self'` does not
  need `'unsafe-eval'`.

## Verification

* `node --check gc2.js` after every compile.
* jsdom regression suite covers: startup with throwing `localStorage`,
  guarded save/load round-trip, closed-form eternal rewards vs. the old loop,
  clamping of a tampered `eternal_stage`, bounded huge-EXP level-ups, hidden
  locked tiles after prestige, 0 HP display, release metadata, and CSP.

## Residual risk / recommendations

1. Upgrade jQuery to 3.7.x (and re-test qtip/nanoscroller/touche) when time
   permits; keep it vendored.
2. If the game is ever hosted where response headers can be set, send CSP as a
   header (with `frame-ancestors 'none'`) instead of a meta tag.
3. Consider a `storage`-event-based multi-tab guard if save collisions are
   reported by players.
4. Battle trophies still grow without bound (see `docs/BUG_AUDIT.md` #1); cap
   the list to the most recent ~50 entries if long sessions are a concern.
