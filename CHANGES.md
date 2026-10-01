# Architecture & Design System Changes

> **Specification Reference:** [antigravity.md](file:///d:/flutter%20projects%202026/my_portfolio/antigravity.md)  
> **Target Design System:** NIKI Studio (`bynikistudio-com`) via Inspo MCP  
> **Backend Architecture:** Supabase Postgres + Realtime + Storage with GitHub Actions Keep-Alive and local JSON snapshot fallback.

---

## 1. Executive Summary

This release transforms the portfolio into an architectural, editorial, and resilient web application modeled after the **NIKI Studio** aesthetic. It permanently solves Supabase free-tier 7-day inactivity pausing via an automated GitHub Actions keep-alive workflow paired with a zero-latency offline snapshot fallback (`assets/content_snapshot.json`). All cosmic/space visual metaphors (galaxy shaders, particle systems, glassmorphic cards) have been replaced with a minimalist **Split Studio** layout, crisp 1px hairline dividers, dual-font typographic hierarchy (`Unbounded` + `Inter Tight`), and an inverted sand/ink contact band.

---

## 2. File Manifest

### Created Files
| File Path | Description |
|:---|:---|
| [DESIGN.md](file:///d:/flutter%20projects%202026/my_portfolio/DESIGN.md) | Design system tokens and layout specs pulled from `https://inspomcp.dev/api/design/bynikistudio-com`. |
| [.github/workflows/supabase-keepalive.yml](file:///d:/flutter%20projects%202026/my_portfolio/.github/workflows/supabase-keepalive.yml) | Automated workflow running every 2 days (`0 6 */2 * *`) to ping PostgREST and Supabase Storage. |
| [tool/export_snapshot.dart](file:///d:/flutter%20projects%202026/my_portfolio/tool/export_snapshot.dart) | CLI script to query Supabase and dump live tables into `assets/content_snapshot.json`. |
| [assets/content_snapshot.json](file:///d:/flutter%20projects%202026/my_portfolio/assets/content_snapshot.json) | Bundled fallback snapshot containing hero, about, experience, tech stack, and project records. |
| [lib/services/snapshot_service.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/services/snapshot_service.dart) | Asset parser service providing instant synchronous initial data when network or Supabase is paused. |
| [KEEPALIVE.md](file:///d:/flutter%20projects%202026/my_portfolio/KEEPALIVE.md) | Dedicated guide on Supabase pausing, GitHub Actions configuration, and snapshot synchronization. |
| [CHANGES.md](file:///d:/flutter%20projects%202026/my_portfolio/CHANGES.md) | Complete record of design system and architectural modifications. |

### Deleted Obsolete Files
| File Path | Reason for Removal |
|:---|:---|
| `lib/widgets/galaxy_background.dart` | Obsolete cosmic visual motif incompatible with NIKI Studio aesthetic. |
| `lib/widgets/floating_particles.dart` | Obsolete animated particle canvas incompatible with minimal editorial design. |
| `lib/widgets/glassmorphism_card.dart` | Replaced by solid architectural hairline containers and stage surfaces. |

### Modified Files
| File Path | Summary of Modifications |
|:---|:---|
| [pubspec.yaml](file:///d:/flutter%20projects%202026/my_portfolio/pubspec.yaml) | Added `assets/content_snapshot.json` to Flutter assets bundle. |
| [lib/theme/app_theme.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/theme/app_theme.dart) | Defined NIKI Studio palette (`#141312` charcoal, `#ba7924` amber, `#e9c28f` sand, `#54240c` ink, `#7c7f80` muted grey), `GoogleFonts.unbounded` display, `GoogleFonts.interTight` body, and 2px border radiuses. |
| [lib/services/supabase_db_service.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/services/supabase_db_service.dart) | Integrated 6-second timeout fallback to `SnapshotService` on initial fetches while preserving continuous live Supabase real-time stream subscriptions. |
| [lib/providers/app_providers.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/providers/app_providers.dart) | Added `backendOfflineProvider` and updated content/project streams with snapshot fallbacks. |
| [lib/widgets/nav_bar.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/widgets/nav_bar.dart) | 64px fixed bar with hairline border, Unbounded wordmark with amber dot, active indicator underlines, and a fullscreen mobile overlay menu. |
| [lib/sections/hero_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/hero_section.dart) | Massive Unbounded display name, live status badge (`AVAILABLE FOR SELECT ROLES`), split metadata row, duotone portrait with amber tint, and direct CV download. |
| [lib/sections/about_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/about_section.dart) | Split Studio 2-column layout (`01 / ABOUT`), architectural key metrics counter, bio, and admin inline editing. |
| [lib/sections/tech_stack_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/tech_stack_section.dart) | Split Studio `02 / STACK`, numbered typographic index list (`01`, `02`, etc.) with hairline dividers, category filters, and admin dialog management. |
| [lib/sections/experience_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/experience_section.dart) | Split Studio `03 / EXPERIENCE`, chronological tabular rows (`years | role & company | details`) with amber active state. |
| [lib/sections/projects_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/projects_section.dart) | Split Studio `04 / WORK`, bespoke project blocks, tech tag chips, admin reorder, and charcoal stage. |
| [lib/widgets/device_frame_mockup.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/widgets/device_frame_mockup.dart) | Architectural iPhone frame on elevated charcoal stage (`#1a1918`) with subtle amber ambient glow, supporting looping HTML5 video with image fallback. |
| [lib/sections/contact_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/contact_section.dart) | Inverted warm sand `#e9c28f` section with deep brown ink `#54240c` typography, 1-click email copy, social links, and message dispatch form. |
| [lib/sections/footer_section.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/footer_section.dart) | Minimal hairline footer with wordmark, copyright notice, and back-to-top interaction. |
| [lib/widgets/editable_text.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/widgets/editable_text.dart) | Styled with thin dashed amber outline (`#ba7924`) and hover `EDIT` chip when admin mode is active. |
| [lib/widgets/editable_image.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/widgets/editable_image.dart) | Admin hover chip for image replacement with Supabase Storage upload. |
| [lib/widgets/editable_media.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/widgets/editable_media.dart) | Admin hover chip for video/media URL updates. |
| [lib/sections/admin_login_screen.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/sections/admin_login_screen.dart) | Restyled to match charcoal/amber theme with Unbounded typography and offline database indicator. |
| [lib/main.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/main.dart) | Updated top-level scaffold and theme provider configuration. |
| [README.md](file:///d:/flutter%20projects%202026/my_portfolio/README.md) | Updated documentation with keep-alive instructions, snapshot maintenance, and design system reference. |

---

## 3. Typography Ramp

| Role | Font Family | Weight | Size (Desktop / Mobile) | Line Height | Letter Spacing |
|:---|:---|:---|:---|:---|:---|
| **Hero Title** | `Unbounded` | 900 Black | 72px / 40px | 1.05 | -0.03em |
| **Section Headings** | `Unbounded` | 800 ExtraBold | 42px / 26px | 1.15 | -0.02em |
| **Project Titles** | `Unbounded` | 800 ExtraBold | 26px / 20px | 1.2 | -0.01em |
| **Card / Item Headings**| `Unbounded` | 700 Bold | 20px / 17px | 1.25 | 0.0em |
| **Eyebrows & Section IDs**| `Inter Tight`| 700 Bold | 12px / 11px | 1.4 | +0.12em (uppercase) |
| **Body & Descriptions**| `Inter Tight` | 400 Regular | 15px / 14px | 1.65 | +0.01em |
| **Meta & Captions** | `Inter Tight` | 500 Medium | 12px / 11px | 1.4 | +0.04em |
| **Buttons & Links** | `Inter Tight` | 700 Bold | 12px / 11px | 1.0 | +0.10em (uppercase) |

---

## 4. Color Palette Tokens

```
Charcoal Base:   #141312  ████  Primary background
Charcoal Stage:  #1a1918  ████  Elevated device / card stage
Amber Accent:    #ba7924  ████  Primary accent, active indicators, amber dot
Amber Glow:      #ba7924  ████  15% opacity radial ambient shadow
Sand Band:       #e9c28f  ████  Inverted contact section surface
Deep Brown Ink:  #54240c  ████  Contact section typography & action buttons
Hairline Border: #242220  ████  1px architectural structure dividers
Muted Gray:      #7c7f80  ████  Secondary body copy, metadata, timestamps
Pure White:      #ffffff  ████  Display headings, primary reading text
```

---

## 5. Supabase Free-Tier Keep-Alive System

### 5.1 The Inactivity Problem
Supabase free tier projects are automatically paused after **7 consecutive days of API inactivity**. Once paused:
1. Public visitors see an empty site or infinite loading spinners.
2. Unpausing requires manual login to the Supabase dashboard and waiting 2–5 minutes.

### 5.2 GitHub Actions Architecture
The workflow located at [.github/workflows/supabase-keepalive.yml](file:///d:/flutter%20projects%202026/my_portfolio/.github/workflows/supabase-keepalive.yml) runs automatically on a scheduled cron:
- **Schedule:** `0 6 */2 * *` (Every 2 days at 06:00 UTC).
- **PostgREST Ping:** `GET $SUPABASE_URL/rest/v1/content?select=section&limit=1` with `apikey` and `Authorization: Bearer` headers.
- **Storage Ping:** `POST $SUPABASE_URL/storage/v1/object/list/portfolio` with payload `{"limit": 1, "prefix": ""}`.
- **Validation:** Both requests use `--fail` to ensure HTTP 200 responses.

### 5.3 Offline Snapshot Fallback
- [lib/services/snapshot_service.dart](file:///d:/flutter%20projects%202026/my_portfolio/lib/services/snapshot_service.dart) loads [assets/content_snapshot.json](file:///d:/flutter%20projects%202026/my_portfolio/assets/content_snapshot.json) on boot.
- If Supabase does not respond within **6 seconds** (or if the project is paused/network offline), the UI immediately populates from the bundled snapshot.
- A persistent warning banner alerts the admin if the backend is offline.
- Background real-time streams continue attempting reconnection so the page seamlessly upgrades to live data once the backend awakens.

### 5.4 Refreshing the Snapshot
Whenever you update your portfolio content via the admin panel, regenerate the snapshot with:
```bash
dart run tool/export_snapshot.dart
```

---

## 6. Recommended Supabase RLS Policies (Review Only)

Ensure your Supabase SQL editor has Row Level Security enabled with public read access and authenticated admin write access:

```sql
-- Enable Row Level Security on all portfolio tables
ALTER TABLE content ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;

-- 1. Content table policies
DROP POLICY IF EXISTS "Public can view content" ON content;
CREATE POLICY "Public can view content" 
  ON content FOR SELECT 
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can update content" ON content;
CREATE POLICY "Authenticated users can update content" 
  ON content FOR ALL 
  TO authenticated 
  USING (true) 
  WITH CHECK (true);

-- 2. Projects table policies
DROP POLICY IF EXISTS "Public can view projects" ON projects;
CREATE POLICY "Public can view projects" 
  ON projects FOR SELECT 
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can manage projects" ON projects;
CREATE POLICY "Authenticated users can manage projects" 
  ON projects FOR ALL 
  TO authenticated 
  USING (true) 
  WITH CHECK (true);

-- 3. Storage bucket 'portfolio' policies
-- Run this in the Supabase Storage dashboard or SQL editor:
-- Allow public downloads
CREATE POLICY "Public Access" 
  ON storage.objects FOR SELECT 
  USING (bucket_id = 'portfolio');

-- Allow authenticated uploads
CREATE POLICY "Authenticated users can upload media" 
  ON storage.objects FOR INSERT 
  TO authenticated 
  WITH CHECK (bucket_id = 'portfolio');

CREATE POLICY "Authenticated users can update media" 
  ON storage.objects FOR UPDATE 
  TO authenticated 
  USING (bucket_id = 'portfolio');

CREATE POLICY "Authenticated users can delete media" 
  ON storage.objects FOR DELETE 
  TO authenticated 
  USING (bucket_id = 'portfolio');
```

---

## 7. Verification Results
- **Code Analysis:** `flutter analyze` executed with **0 issues found**.
- **Production Build:** `flutter build web --release` compiled successfully (**0 errors**).
- **Responsive Layout Verification:** Verified across desktop (1440x900) and mobile (390x844) viewports.
