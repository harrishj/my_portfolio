# Flutter Web Portfolio — NIKI Studio Edition

A high-performance Flutter web portfolio featuring a "Split Studio" architectural layout inspired by [NIKI Studio](https://bynikistudio.com/), powered by Supabase for dynamic content management, real-time sync, and offline snapshot resilience.

---

## Supabase Pausing & Keep-Alive

To prevent the Supabase free tier from automatically pausing after 7 days of inactivity:
- A GitHub Actions workflow runs every 2 days (`.github/workflows/supabase-keepalive.yml`) pinging the database REST API and storage bucket.
- An offline content snapshot (`assets/content_snapshot.json`) ensures the site renders instantly even if Supabase is sleeping or unreachable.
- See [`KEEPALIVE.md`](KEEPALIVE.md) for full instructions on configuring GitHub secrets and re-arming the workflow.

### Refreshing Content Snapshot
```bash
dart run tool/export_snapshot.dart
```

---

## Recommended Row Level Security (RLS) Policies (Review Only)

Execute the following SQL in your Supabase SQL editor to secure `content`, `projects`, and the `portfolio` storage bucket:

```sql
-- 1. Enable RLS on public tables
ALTER TABLE public.content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- 2. Policies for 'content' table
CREATE POLICY "Allow public select on content"
  ON public.content FOR SELECT TO public USING (true);

CREATE POLICY "Allow authenticated insert on content"
  ON public.content FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on content"
  ON public.content FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated delete on content"
  ON public.content FOR DELETE TO authenticated USING (true);

-- 3. Policies for 'projects' table
CREATE POLICY "Allow public select on projects"
  ON public.projects FOR SELECT TO public USING (true);

CREATE POLICY "Allow authenticated insert on projects"
  ON public.projects FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on projects"
  ON public.projects FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated delete on projects"
  ON public.projects FOR DELETE TO authenticated USING (true);

-- 4. Policies for 'portfolio' storage bucket
CREATE POLICY "Allow public read access on portfolio bucket"
  ON storage.objects FOR SELECT TO public USING (bucket_id = 'portfolio');

CREATE POLICY "Allow authenticated insert on portfolio bucket"
  ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'portfolio');

CREATE POLICY "Allow authenticated update on portfolio bucket"
  ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'portfolio') WITH CHECK (bucket_id = 'portfolio');

CREATE POLICY "Allow authenticated delete on portfolio bucket"
  ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'portfolio');
```
