# CastroEduConnect 🚀

**Connecting Learners, Empowering Futures.**

A Learning Management System built with HTML5, Tailwind CSS, vanilla JavaScript, and Supabase
(PostgreSQL + Auth). This package is your uploaded project, audited and repaired so the
frontend and backend actually agree with each other.

---

## What was wrong, and what I fixed

Your app's pages (`dashboard.html`, `subjects.html`, `assignments.html`, `assessments.html`,
`resources.html`, `results.html`, `login.html`, `register.html`) already had real Supabase
queries wired in — that part of the build was solid. The problems were all in the database
layer and three pages that were still static mockups:

1. **`supabase-schema.sql` could not run at all.** Every table used `id UUID DEFAULT
   uuid-ossp() PRIMARY KEY`. `uuid-ossp()` isn't a function — the extension is named
   `uuid-ossp` but the function it provides is `uuid_generate_v4()`. Every single `CREATE
   TABLE` statement would have failed. **Fixed:** all 20+ tables now use `uuid_generate_v4()`.

2. **New users always registered as blank learners, no matter what they picked.**
   `register.html` correctly sends `first_name`, `last_name`, and `role` when it calls
   `supabase.auth.signUp()`, but the database trigger `handle_new_user()` ignored that data
   entirely and hard-coded `''`, `''`, `'learner'`. A teacher signing up would silently
   become a nameless learner. **Fixed:** the trigger now reads
   `NEW.raw_user_meta_data->>'first_name'` etc., with safe fallbacks.

3. **Row Level Security was full of holes.** Only 9 of the ~20 tables had any policy at all,
   so most inserts/updates from the app (creating a subject, submitting an assignment, liking
   a resource, posting an announcement) would have been silently rejected by Postgres.
   **Fixed:** every table now has SELECT/INSERT/UPDATE/DELETE policies matched to what the
   app actually does — learners manage their own enrollments/submissions, teachers manage
   subjects/assessments they own, admins can manage everything.

4. **Two tables the app queries didn't exist in the schema**: `resource_likes` and
   `resource_comments` (used by `resources.html`). **Fixed:** added both, plus `topics`,
   `sub_topics`, `class_enrollments`, `discussions`, and `discussion_comments` from your
   original spec so the schema is ready if you build those pages out later.

5. **`resources.html` inserts a comment as `{ comment: ... }`** but the schema had
   `comment_text`. **Fixed:** schema column renamed to `comment` to match the app.

6. **Submission status `'pending'`** is used throughout `assessments.html`/`assignments.html`
   for essays awaiting grading, but the old CHECK constraint didn't allow it — every essay
   submission would have thrown a database error. **Fixed:** added to the allowed list.

7. **Dashboard average-score stat was always "N/A".** `loadStats()` selected
   `status, total_score, total_marks` from `submissions` but then filtered/averaged on
   `s.percentage`, a column it never fetched. **Fixed:** `percentage` added to the select.

8. **`profile.html`, `settings.html`, and `announcements.html` were static demo pages**
   (hard-coded "John Doe", fake numbers, a "Post Announcement" button that did nothing).
   **Rebuilt from scratch** with the same look, now backed by real Supabase calls:
   - Profile: loads/edits your real name, phone, city, bio; live stats (enrolled subjects,
     average score, completed assessments) computed from your actual `subject_enrollments`
     and `submissions`; real password change via `auth.updateUser()`.
   - Settings: real dark-mode toggle, notification prefs (stored per-user), and an account
     deletion request that's logged to `activity_logs` for an admin to action (the client SDK
     can't delete a user's own auth account directly — that needs a service-role key on a
     server, which is why this asks an admin rather than deleting on the spot).
   - Announcements: loads real announcements from the database, searchable, with a working
     "Post Announcement" flow for teachers/admins (visible only to those roles).

9. **`resources.html`'s drag-and-drop upload was already wired to Supabase Storage**
   (`supabaseClient.storage.from('resources').upload(...)`) — but the schema never created
   that storage bucket, so every upload would have failed with a "bucket not found" error.
   **Fixed:** `supabase-schema.sql` now creates the `resources` bucket (public read, any
   signed-in user can upload) with storage-level RLS policies.

10. **Two whole features were missing entirely** — the original spec called for an admin
    console and a discussion forum, and the schema/RLS were ready for both, but no pages
    existed. **Built from scratch:**
    - `admin.html` — a tabbed console (Overview / Users / Grades / Classes / Subjects) for
      admin accounts only. Promote/demote roles, suspend accounts, and full CRUD on grades,
      classes, and subjects (including teacher assignment), plus live platform-wide stats.
    - `discussions.html` — a per-subject discussion forum: start a thread, reply, upvote,
      and (for teachers/admins) pin, close, or mark a reply as the best answer.

11. **Clicking into an enrolled subject only opened a shallow info popup** — no notes, no
    topics, no organized resources, and no way for a teacher to add any of that short of
    the raw Table Editor. **Built `subject-detail.html`** — a Moodle-style course page:
    - Students see the subject's topics as an accordion, each with its notes/lesson content
      (and optional video links) and any resources filed under that topic, plus a "General
      Resources" section for subject-wide files.
    - Teachers (who own the subject) and admins get an inline management bar on the same
      page — add/edit/delete topics, add/edit/delete notes under each topic, and upload
      resources (PDF, Word, PowerPoint, images, video, audio, zip) straight into Supabase
      Storage, scoped to a specific topic or general. No separate admin screen needed for
      day-to-day content — it's managed right where students see it, the way Moodle's
      course page works.
    - `subjects.html`'s "View" button now opens this page instead of the old info-only
      popup.

12. **Assessment/assignment questions couldn't be answered at all — this is why marking
    never worked.** Both `assessments.html` and `assignments.html` build each answer
    choice's `onclick` handler as a plain JavaScript template string:
    `onclick="selectChoice(${q.id}, ${idx})"`. Question IDs are UUIDs (e.g.
    `3fa85f64-5717-4562-...`), and dropping one into that attribute **unquoted** produces
    invalid JavaScript — `selectChoice(3fa85f64-5717-4562-...)`, which the browser tries to
    parse as subtraction between undefined variables and fails silently. Clicking an answer
    (or typing a short answer) did nothing, `currentAttempt.answers` stayed empty, and every
    submission scored zero. **Fixed:** the question ID is now quoted as a string in every
    `onclick`/`onchange` handler across both files (6 occurrences), so selecting an answer,
    typing a short answer, and auto-marking on submit all work correctly.

Everything else — your Bento-style layout, glassmorphism, dark mode, the assignment/quiz
engine with auto-marking, the subjects/enrollment flow, the resources library — was already
built and is untouched other than the fixes above. Every page's sidebar now links to
Discussions and Admin Console too (the admin link is gated inside `admin.html` itself — any
non-admin who clicks it sees an access-denied message and a button back to their dashboard).

---

## Setup (10 minutes)

### 1. Create/confirm your Supabase project
You already have one configured in the code:
`https://kfeqmjveemfacrmqrhzk.supabase.co`. If you want a fresh project instead, create one
at supabase.com and update `SUPABASE_URL` / `SUPABASE_ANON_KEY` in every HTML file (search
for `SUPABASE_URL` — it's the same two lines near the bottom of each page).

### 2. Run the schema
Open **Supabase Dashboard → SQL Editor → New query**, paste the entire contents of
`supabase-schema.sql`, and run it. It's safe to re-run any time — it drops and recreates
everything, so **don't run it against a project with real data you want to keep.**

### 3. Set your auth settings
Go to **Authentication → Providers → Email**. For quick local testing, turn off "Confirm
email" so new accounts can log in immediately. For a real deployment, leave confirmation on.

### 4. Register your first accounts
Open `register.html` (or your deployed URL) and create:
- One account with role **Administrator**
- One account with role **Teacher**
- One or more accounts with role **Learner**

Because self-service admin signup is a real security risk in production, consider removing
the "Administrator" option from `register.html`'s role dropdown once you've created your own
admin account, and promote future admins manually:

```sql
UPDATE public.profiles SET role = 'admin' WHERE email = 'you@example.com';
```

### 5. Assign the teacher to a subject
The seed data creates 5 sample Grade 1 subjects with no teacher assigned. In **Table Editor →
subjects**, set `teacher_id` to your teacher account's `id` (copy it from **Table Editor →
profiles**) for any subject you want them to manage. Then, as the learner, go to
`subjects.html` and enroll.

### 6. Open the app
Just open `index.html` in a browser, or deploy the whole folder (see below) — there's no
build step, it's static HTML/CSS/JS talking straight to Supabase.

---

## Deploying

Any static host works (GitHub Pages, Netlify, Vercel, Cloudflare Pages). For GitHub Pages:

```bash
git init
git add .
git commit -m "CastroEduConnect"
git branch -M main
git remote add origin https://github.com/<you>/castroeduconnect.git
git push -u origin main
```

Then in the repo: **Settings → Pages → Deploy from branch → main → / (root)**.

---

## Project structure

```
├── index.html              Public landing page
├── login.html               Supabase email/password login
├── register.html            Sign up (learner/teacher/admin)
├── forgot-password.html     Password reset request
├── dashboard.html            Role-aware dashboard with live stats
├── subjects.html             Browse/enroll in subjects
├── subject-detail.html         Moodle-style course page: topics, notes, resources (new)
├── assignments.html          Assignment list, attempt flow, auto-marking
├── assessments.html          Quiz/CAT/exam builder & attempt flow
├── results.html              Grades & performance
├── resources.html            Learning materials, likes & comments
├── announcements.html        School-wide announcements (now live)
├── discussions.html           Per-subject discussion forum (new)
├── admin.html                  Admin console: users, grades, classes, subjects (new)
├── profile.html              Your profile, editable (now live)
├── settings.html             Preferences & account (now live)
├── script.js                  Shared toast/skeleton/format helpers
├── style.css                   Global styles, dark mode, animations
├── logo.png                     Your brand mark (not yet wired into the UI —
│                                 swap it in for the icon div in each page's
│                                 nav/sidebar if you want it on screen)
└── supabase-schema.sql        Full database schema — fixed & extended
```

## Known limitations / good next steps

- **Self-registration allows picking "Administrator"** — fine for a demo, but restrict this
  before going live (see step 4 above).
- The account-deletion flow logs a request for an admin to action, rather than deleting
  immediately — deleting a user's own `auth.users` row requires a service-role key, which
  can't safely live in client-side code.
- Storage RLS lets any authenticated user upload to the `resources` bucket path they choose;
  if you want to lock uploads to teachers/admins only, tighten the
  `resources_bucket_authenticated_upload` policy in `supabase-schema.sql` to check the
  uploader's role.
