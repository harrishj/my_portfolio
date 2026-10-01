# Supabase Keep-Alive & High Availability Guide

This guide details how to keep your Supabase project active on the free tier (preventing automatic pausing after 7 days of inactivity), how the bundled offline snapshot works, and the recommended Row Level Security (RLS) policies.

---

## 1. GitHub Actions Keep-Alive Workflow

A scheduled GitHub Actions workflow is located at [`.github/workflows/supabase-keepalive.yml`](.github/workflows/supabase-keepalive.yml).

### Schedule
- Runs every 2 days at 06:00 UTC (`0 6 */2 * *`), well within the 7-day inactivity pause window.
- Can also be triggered manually (`workflow_dispatch`).

### What It Does
1. Performs an HTTP GET with `--fail` against the Supabase PostgREST API:
   ```bash
   curl --fail -sS "$SUPABASE_URL/rest/v1/content?select=section&limit=1" \
     -H "apikey: $SUPABASE_ANON_KEY" \
     -H "Authorization: Bearer $SUPABASE_ANON_KEY"
   ```
2. Performs an HTTP POST with `--fail` against the Supabase Storage Object List API:
   ```bash
   curl --fail -sS "$SUPABASE_URL/storage/v1/object/list/portfolio" \
     -X POST \
     -H "apikey: $SUPABASE_ANON_KEY" \
     -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
     -H "Content-Type: application/json" \
     -d '{"limit": 1, "prefix": ""}'
   ```
3. A 2xx response (even `[]`) registers database and storage activity with Supabase, preventing the auto-pause. A non-2xx failure halts the workflow so GitHub immediately emails you.

### Setup Instructions
1. Push your repository to GitHub.
2. In your GitHub repository, navigate to **Settings** → **Secrets and variables** → **Actions**.
3. Under **Repository secrets**, click **New repository secret** and add:
   - `SUPABASE_URL`: `https://slwbsiebuoranrtidcxe.supabase.co` (or your project URL)
   - `SUPABASE_ANON_KEY`: Your project's anon/public key.
4. Go to the **Actions** tab, select **Supabase Keep-Alive**, click **Run workflow**, and confirm that both database and storage steps pass with a green checkmark.

### Important: GitHub 60-Day Inactivity Rule
- GitHub automatically disables scheduled workflows for repositories that have had no commits or activity for 60 consecutive days.
- If disabled, simply push any commit, or go to the **Actions** tab on GitHub and click **Enable workflow** to re-arm it.
- If your Supabase project was already paused prior to configuring this, log in to the [Supabase Dashboard](https://supabase.com/dashboard) and click **Restore project** once.

---

## 2. Bundled Content Snapshot (Offline Fallback)

To guarantee that your portfolio never shows an empty screen even during network drops or if Supabase is temporarily unreachable:
- All section text and projects are pre-baked into [`assets/content_snapshot.json`](assets/content_snapshot.json).
- On initial web app boot, the data layer attempts to connect to Supabase with a **6-second timeout**.
- If Supabase does not respond within 6 seconds or returns an error, the app gracefully seeds Riverpod providers from `assets/content_snapshot.json` so visitors immediately see your content.
- In the background, the app keeps listening to the live Supabase stream. Once Supabase responds or reconnects, the UI seamlessly updates with live data.

### How to Refresh the Snapshot
Whenever you make significant additions or edits to your projects or section copy via admin mode, re-generate the snapshot file and commit it:
```bash
dart run tool/export_snapshot.dart
```
This reads directly from Supabase using your anon key, writes formatted JSON to `assets/content_snapshot.json`, and reports file size.

---

## 3. Row-Level Security (RLS) Policies (Review Only)

Here is the SQL to verify in your [Supabase SQL Editor](https://supabase.com/dashboard):

```sql
-- Enable RLS
ALTER TABLE public.content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- Content table: Public read, Admin write
CREATE POLICY "Allow public select on content"
  ON public.content FOR SELECT TO public USING (true);

CREATE POLICY "Allow authenticated insert on content"
  ON public.content FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on content"
  ON public.content FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated delete on content"
  ON public.content FOR DELETE TO authenticated USING (true);

-- Projects table: Public read, Admin write
CREATE POLICY "Allow public select on projects"
  ON public.projects FOR SELECT TO public USING (true);

CREATE POLICY "Allow authenticated insert on projects"
  ON public.projects FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on projects"
  ON public.projects FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated delete on projects"
  ON public.projects FOR DELETE TO authenticated USING (true);

-- Storage bucket 'portfolio': Public read, Admin write
CREATE POLICY "Allow public read access on portfolio bucket"
  ON storage.objects FOR SELECT TO public USING (bucket_id = 'portfolio');

CREATE POLICY "Allow authenticated insert on portfolio bucket"
  ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'portfolio');

CREATE POLICY "Allow authenticated update on portfolio bucket"
  ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'portfolio') WITH CHECK (bucket_id = 'portfolio');

CREATE POLICY "Allow authenticated delete on portfolio bucket"
  ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'portfolio');
```
