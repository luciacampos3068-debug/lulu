# Supabase setup

1. Create a Supabase project and copy its project URL and public anon/publishable key.
2. Copy `.env.example` to `.env.local`, replace both example values, then run `npm run build`.
   Never put a `service_role` key in `.env.local` or browser code.
3. Run `supabase-schema.sql` in the Supabase SQL editor.
4. Create the first user in Supabase Authentication. In the SQL editor, promote that user's profile:

   ```sql
   update public.profiles
   set role = 'admin'
   where email = 'admin@example.com';
   ```

5. Install the Supabase CLI, log in, link this project, and deploy the invite function:

   ```text
   supabase functions deploy invite-editor
   ```

   Supabase provides `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and
   `SUPABASE_SERVICE_ROLE_KEY` to deployed Edge Functions. The privileged key
   is used only by the server-side invite function.
6. For local development, use `npm run dev`. To publish on GitHub Pages:

   - Push this project to a GitHub repository with a `main` branch.
   - In repository **Settings → Secrets and variables → Actions → Variables**,
     add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` with the public project
     URL and anon/publishable key.
   - In **Settings → Pages**, select **GitHub Actions** as the build and deploy
     source. The included workflow publishes on each push to `main`.
   - Add the Pages URL to the Supabase Auth **Site URL** and allowed redirect URLs.

   The workflow derives the correct Vite base path from the GitHub repository
   name. The published site is static; Supabase provides cloud authentication
   and shared memories.

   Alternatively, for a public Google-hosted link:

   - Create a Firebase project in the Google Firebase Console and enable Firebase Hosting.
   - Install the Firebase CLI, run `firebase login`, then `firebase use --add` and select that project.
   - Make sure `.env.local` has the Supabase project URL and public key.
   - Run `npm run build` followed by `firebase deploy --only hosting`.
   - Share the `https://<project-id>.web.app` URL shown by Firebase.

   Firebase hosts the page; Supabase provides cloud authentication and shared
   memories. Supabase auth, profiles, memories, moods, activity, editor
   invitations, and realtime memory updates use the cloud. Cover settings,
   letters, capsules, and audio/image settings remain in each browser's IndexedDB.

The PIN gate is only an additional local UI lock; it is not encryption or an
authentication mechanism. Supabase RLS policies are the authorization boundary
for cloud data.

The first administrator must promote their profile using the SQL above. The
administrator can then invite editors from the app; invited users receive a
Supabase email invitation and must accept it before signing in.
