# NIKI Studio design system

> Extracted by [Inspo](https://github.com/Nutlope/inspo) (open source, MIT, powered by Together AI). Reference material for *intentional* design decisions: adapt, don't copy.
> Save this as `DESIGN.md` in your project and re-reference it as you build; re-fetch anytime at https://inspomcp.dev/d/bynikistudio-com/DESIGN.md

- **Source:** https://bynikistudio.com/
- **Captured:** 2026-05-27
- **Mode:** dark
- **Macrostructure:** Split Studio
- **Stack:** Framer

## Tone

Digital Design Studio - Viet Nam · minimalism, dark-mode, monochrome, agency, portfolio, hero-fullbleed, logo-cloud, feature-trio

## Colors

| Hex | Role (heuristic) |
|---|---|
| `#ba7924` | support (amber) |
| `#e9c28f` | support (sand) |
| `#54240c` | accent (deep brown / ink) |
| `#7c7f80` | support (muted grey) |
| `#c0c4c4` | support (light grey / detail) |
| `#141312` to `#1a1918` | background (deep charcoal) |

## Typography

Detected typefaces: **Monument Extended Ultrabold**, **sans-serif**
Flutter equivalent: **Unbounded** (weights 800-900) or **Syne** (800) for Display Headings; **Inter Tight** / **Inter** for Body and Meta.

| Role | Family | Size | Weight | Line-height | Letter-spacing |
|---|---|---|---|---|---|
| h1 | Monument Extended Ultrabold / Unbounded | 100-140px (desktop) / 44-56px (mobile) | 800-900 | ~0.75-0.85 | slightly tight |
| h3 / section header | Uppercase / Unbounded or Inter Tight | 13-16px | 700-800 | 1.2 | uppercase, spaced |
| body | Inter Tight / Inter | 12-14px | 400-500 | 1.4-1.6 | 0 |
| button / meta | Inter Tight / Inter | 12-13px | 600-700 | 1.4 | letter-spaced uppercase |

## Spacing scale

`16px` base (multiples of 8px on a 16px base: 8, 16, 24, 32, 48, 64, 80, 96, 120)

## Border radius

`2px` (minimal 0-4px radius, crisp architectural edges)

## Macrostructure

**Split Studio**: Split layouts with sticky left column (`01 / ABOUT`, `02 / STACK`, etc.) and content on the right. 1px hairline dividers (`#7c7f80` with low opacity / `#2a2826`).
