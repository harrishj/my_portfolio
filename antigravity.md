# Master prompt: Flutter portfolio — NIKI Studio redesign + Supabase "never pause" fix

Paste everything below the line into the Antigravity agent, with the portfolio project open as the workspace.

---

You are working on my existing Flutter web portfolio (this workspace). It uses flutter_riverpod, google_fonts, supabase_flutter, video_player and device_frame. Content lives in the Supabase tables `content` (one row per section, jsonb `data`) and `projects`. Media (app demo videos and images, profile image, resume PDF) lives in the Supabase storage bucket `portfolio`. There is a Supabase-auth admin login (`lib/sections/admin_login_screen.dart`) and inline editable widgets (`lib/widgets/editable_text.dart`, `editable_image.dart`, `editable_media.dart`). These let me edit every section (summary, skills, experience, projects, project order, media, resume) element by element. My app work is shown as real mobile screens: videos and images inside an iPhone frame (`lib/widgets/device_frame_mockup.dart`, `lib/sections/projects_section.dart`).

There are two jobs: (A) fix the Supabase free-tier pausing problem, and (B) redesign the whole site in the style of the Inspo reference "NIKI Studio". Stay in Flutter. Do not migrate to another framework.

## Hard rules
- Do not break any functionality. All Supabase reads and streams, admin login and logout, every inline edit, adding, deleting and reordering projects, media and resume uploads, and the Riverpod providers must work exactly as before.
- Do not rename tables, columns, storage buckets or content keys. Do not run destructive SQL. Do not change the Supabase project settings.
- Change presentation, not data logic, unless a step below says otherwise.
- Never print or commit any secret other than the existing public anon key that is already in `lib/supabase_config.dart`.
- Work in small steps. Run `flutter analyze` after each major step and fix new errors before moving on.

## Step 0: Connect the Inspo design MCP
1. Add the Inspo MCP server to Antigravity's MCP config at `~/.gemini/antigravity/mcp_config.json`, registered under the name `inspo`. It is a free, hosted, no-auth streamable-HTTP endpoint:
   ```json
   {
     "mcpServers": {
       "inspo": { "serverUrl": "https://inspomcp.dev/api/mcp" }
     }
   }
   ```
   Merge this with any servers already in the file; don't overwrite them. If the remote server can't be reached, use the local stdio form instead:
   ```json
   "inspo": { "command": "npx", "args": ["-y", "inspo-mcp"] }
   ```
2. List the inspo tools back to me so I know it connected.
3. Use the inspo tools to fetch the full design system for the screen `bynikistudio-com` (https://inspomcp.dev/screens/bynikistudio-com). If the tools aren't available, fetch https://inspomcp.dev/api/design/bynikistudio-com directly. Read it fully before writing any UI code.

## Step 1: Fix the Supabase pausing problem (no more manual restarts)
The free tier pauses a project after about 7 days without activity. While it is paused, the site has no content and no app videos.
1. **Keep-alive job.** Create `.github/workflows/supabase-keepalive.yml`:
   - Triggers: `schedule` with cron `0 6 */2 * *` (every 2 days) and `workflow_dispatch`.
   - One job on `ubuntu-latest` that runs `curl --fail -sS "$SUPABASE_URL/rest/v1/content?select=section&limit=1" -H "apikey: $SUPABASE_ANON_KEY" -H "Authorization: Bearer $SUPABASE_ANON_KEY"`, with both values read from repo secrets `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Also list one file from the storage bucket using the storage list API, so storage gets activity too.
   - A 200 response with `[]` is fine, because it still counts as activity. A non-2xx response must fail the job so GitHub emails me.
2. **Offline fallback for text content.** Add a bundled snapshot so the site still renders if Supabase is ever unreachable.
   - Add a small Dart script, `tool/export_snapshot.dart`, run with `dart run tool/export_snapshot.dart`. It reads all rows of `content` and `projects` with the anon key and writes `assets/content_snapshot.json`. Register that file under assets in `pubspec.yaml`.
   - In the data layer, the first load should try Supabase with a ~6-second timeout. On failure or timeout, seed the providers from the snapshot, then keep listening to the live streams when they connect.
   - Admin editing still requires live Supabase. If it's unreachable, show a clear "Backend offline" message in admin mode.
3. **Security check (report only).** Look at the RLS (row-level security) policies I'd need and list them in the README. Public `select` should be allowed on `content` and `projects`. `insert`, `update` and `delete` on those tables, and uploads to the `portfolio` bucket, should be allowed only for authenticated users. Don't change policies yourself; give me the SQL to review.
4. Write `KEEPALIVE.md` covering:
   - Push to GitHub, add the two secrets (repo Settings → Secrets and variables → Actions), then run the workflow once manually.
   - GitHub turns off scheduled workflows after 60 days with no repo activity. Any commit, or clicking "Enable workflow" in the Actions tab, re-arms it.
   - If the project is already paused, restore it once from the Supabase dashboard.
   - How to refresh the snapshot.

## Step 2: Redesign in the NIKI Studio style
Follow the Inspo design system from Step 0. Known tokens (treat them as reference, not a recipe):
- **Mode:** dark. Deep charcoal page background (around `#141312` to `#1a1918`). Cool, precise, digital stillness.
- **Macrostructure: "Split Studio".** Split layouts: a large label or heading column on one side (sticky on desktop) and the content on the other. Hairline 1px dividers in a muted grey. Generous whitespace. Numbered sections like `01 / ABOUT`, `02 / STACK`.
- **Palette:** dominant `#ba7924` (amber), surface `#e9c28f` (sand), ink `#54240c` (deep brown), accent `#7c7f80` (grey), detail `#c0c4c4` (light grey). Use amber sparingly for accents, hover states, rules and active nav. Use sand for occasional inverted blocks (for example a contact band in sand with deep brown text). Build hierarchy from type scale and weight, not colour.
- **Typography:** the original display face is Monument Extended Ultrabold, which is paid. Use a free extended lookalike from `google_fonts`: `Unbounded` at weight 800–900 (fallback `Syne` 800). Display headings are uppercase and huge: about 100–140px on desktop, scaling down to ~44–56px at 375px wide. Line height is about 0.85 with slightly tight tracking. Body text and meta labels use `Inter Tight` (fallback `Inter`) at 12–14px, with uppercase, letter-spaced meta labels.
- **Motion:** subtle and precise only. Heading lines slide up and fade in on scroll, hover underlines draw from the left, and phone frames lift slightly with parallax on hover. Respect reduced motion.
- **Remove from the public UI:** the galaxy background, floating particles and glassmorphism cards. Delete those widgets only if nothing else uses them.

Apply the style across:
1. `lib/theme/app_theme.dart`: one source of truth for colours, text styles, spacing (multiples of 8 on a 16px base) and a minimal radius (0–4px).
2. **Nav bar:** a thin top bar with my name or wordmark on the left, uppercase small links on the right, and amber for the active link. On mobile, a full-screen overlay menu with giant display-type links.
3. **Hero:** my name or role in giant extended type across the width. A split meta row underneath with location, availability and a short intro line, a "Resume" link, and socials. Keep my profile image (editable) if one exists, in a duotone or grayscale treatment with an amber tint.
4. **About:** split studio. The left column has `01 / ABOUT` sticky. The right column has the editable summary in large readable text plus quick facts.
5. **Tech stack and skills:** typographic lists in columns with hairline separators. No icon soup. Keep the admin "add skill" and "edit skill" flows working.
6. **Experience:** a timeline as rows: years | role and company | short description. Hairlines between rows and amber on hover.
7. **Projects (the most important part):** each project is a split block. One side has a big project title, number, description, tech tags and platform, GitHub, demo, Play Store and App Store links. The other side has the iPhone frame on a charcoal stage with a soft amber glow, and the demo video autoplays muted on a loop (keep the current video_player behaviour and image fallback). Keep add, delete, reorder and media upload working in admin mode. On mobile, stack the frame above the text.
8. **Contact:** an inverted sand band with deep brown text, a giant "LET'S TALK" heading, email and socials, and the existing contact behaviour.
9. **Footer:** minimal, with a hairline, ©, socials and a back-to-top link.
10. **Admin login and admin mode:** restyle the login screen to match (charcoal, extended heading, minimal inputs). In admin mode, editable elements get a thin amber dashed outline and a small "EDIT" chip on hover so it's obvious what can be edited.
11. **Responsiveness:** test at 375, 768, 1280 and 1440 widths. Nothing overflows. Headings scale smoothly.

## Step 3: Verify and hand over
1. Run `flutter pub get`, then `flutter analyze` (no new errors or warnings from your changes), then `flutter build web --release`.
2. Run it with `flutter run -d chrome`. Check the public site with live data, then log into admin and confirm these still work: editing the summary, adding a skill, editing a project, uploading a project video, reordering projects, uploading the resume, and logging out.
3. Take screenshots of the hero, projects and contact sections at desktop and mobile widths and show them to me.
4. Write `CHANGES.md` with the files changed, fonts, palette, the keep-alive setup, the snapshot command, and the RLS SQL to review.
5. Finish by telling me exactly what I need to do by hand: add the GitHub secrets, run the workflow once, and refresh the snapshot after big content edits.
