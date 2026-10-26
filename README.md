# OTV — installation and handover

This delivery implements the core of the supplied brief in a static HTML/CSS/JavaScript frontend, with Supabase integration and a SQL migration. The public site deliberately starts with no invented programmes, news, broadcasts or audience figures. Neutral artwork panels follow the supplied mockup. The logo is a typographic approximation; replace it with an original standalone OTV logo asset when available.

## Current status

The public interface runs without configuration. Database features require a Supabase project, migration and public connection details. No Supabase project was provided during development, so authentication, database persistence, uploads and permission enforcement have NOT been integration-tested against a live backend. Do not treat this as a fully verified production system yet.

Included: public home, shows, programme and episode pages, news, article reader, schedule, live hub and offline state, search, account forms, password reset, favourites, contributor applications, owner/developer control rooms, create/edit/delete content forms, review and publication status, timed publication, image uploads, owner approval RPC, permission editor, homepage settings, basic scheduled theme accents/headline and activity log. All database operations use the signed-in user's token. No privileged key is used in the frontend.

The broad brief also includes features beyond this core delivery: a rich visual article editor, relational category/tag/season management, assigned collaborators, watchlist separate from favourites, profile image management, media usage/deletion UI, calendar drag-and-drop, theme history/banners/effects, maintenance mode, social links management and automatic YouTube metadata/live verification. These are not implemented. Article content currently uses safe plain text paragraphs; seasons are episode numbers, categories/tags are editable text. Theme changes currently affect accents/headline and respect start/end dates. Manual live status is clearly labelled and is never inferred from the schedule.

## 1. Create the backend

1. Create a Supabase project that you own.
2. Open its SQL Editor. Run `001_setup.sql` once in a new project. This creates the tables, row-level policies, approval function, audit triggers and image bucket in a transaction.
3. Open Project Settings → API. Copy the project URL and publishable key (or legacy anon key) into `config.js`:

```js
window.OTV_CONFIG = {
  supabaseUrl: 'https://YOUR_PROJECT.supabase.co',
  supabaseKey: 'YOUR_PUBLIC_PUBLISHABLE_KEY'
};
```

These are public configuration values. Never use a secret key, service-role key, database password or JWT signing secret. Authorisation is enforced by SQL RLS, not by keeping this public key hidden.

4. In Supabase Authentication → URL Configuration, set the Site URL to your deployed OTV base URL. Add the base URL and the account/reset redirect URLs to the allowed redirects. For local testing also allow `http://127.0.0.1:4173/`. Keep email confirmation enabled. Configure your email sender for reliable verification/reset delivery.
5. Deploy the updated `config.js` with the rest of the website. Use the same Supabase project for the public and team interfaces.

Authentication API: https://supabase.com/docs/reference/javascript/auth-signinwithpassword
RLS reference: https://supabase.com/docs/guides/database/postgres/row-level-security

## 2. Create your owner account

1. Visit OTV → Your account → Sign up, then confirm the verification email.
2. In `002_owner.sql`, replace the placeholder email with your exact verified email.
3. Run that SQL in the Supabase project SQL Editor. Verify the returned administrator list contains only the intended account.
4. Sign out and sign back in. Your account now has an Open control room button.

No public browser endpoint can bootstrap an owner or self-assign a role. The owner account is assigned only through trusted project administration. Keep at least one owner account; this UI does not provide removal of the last owner.

## 3. Publish your first programme

1. Control room → Media Library: upload JPEG, PNG or WebP artwork, at most 5 MB, and copy its URL. Uploaded artwork uses a public bucket, so do not upload confidential files.
2. Shows → Create show. Add title, descriptions, category, creator and optional artwork URLs. Check featured for homepage placement. Save as draft or published.
3. Episodes → Create item. Select the programme, paste a YouTube link or iframe snippet, fill in the episode details and publish. Only the validated YouTube video ID is embedded. No supplied iframe HTML is executed.
4. Newsroom → Create article. Write the headline and body, add author/category and optionally select a related programme. Publish when ready.
5. A published item with a future publication date is withheld by database rules until that time. Public pages refresh every minute, so no background scheduler is required for publication visibility.
6. Schedule / Live Control: add start/end times and a YouTube feed. A schedule entry does not start a broadcast. Explicitly set the broadcast status to live only when appropriate, then ended when finished.

Dates entered in forms use the editor's local timezone and are stored in UTC. Public schedule times use the configured IANA timezone, default Europe/London.

## 4. Contributors

Contributors create and verify ordinary accounts, then use Create with us to submit an application. The owner approves or rejects in Developer Applications. Approval grants programme, episode and article draft permissions; publishing stays off by default. Users & Permissions controls those capabilities. Developers can edit only their own content, cannot reassign ownership, and can attach episodes only to their own programmes. Only owners can approve applications or change roles. Developers without publication permission can submit for review; the owner edits the item and changes its status to published.

## 5. Website settings

Website Management edits the homepage headline, description, banner, footer, contact email, timezone, section order and hidden sections. Section keys are `hero,shows,live,episodes,news`. Preview displays the proposed homepage before saving. Hidden `live` also disables the live route.

Website Themes selects default, Christmas, Halloween, UK election, US midterms or special event. Set an optional `#rrggbb` accent and homepage headline. Dates activate/remove the override automatically when pages render. Clear dates for immediate activation. Theme changes never remove programme content.

## 6. GitHub Pages

The deployable site files are all at the top level of this folder; no Node server is required for hosting. Create a repository and publish those files at the repository root on your chosen Pages branch. In GitHub Settings → Pages choose that branch and root folder. Hash-based navigation works on project Pages URLs without rewrite rules. Keep the SQL and this guide outside the published root if you prefer. Never commit private keys.

For local preview, serve this folder with any static web server. No build step or package installation is required. Upload index.html, style.css, app.js and config.js directly to your GitHub Pages repository root. The SQL files are run in Supabase; GitHub Pages does not run SQL.

## Verification before public launch

Completed here: JavaScript syntax check, eight YouTube input validation cases, public homepage visual inspection and Shows navigation, disconnected account state. Responsive CSS covers phone/tablet/desktop; a full device matrix has not been verified. Live database tests remain blocked until a project is connected.

Use separate owner, contributor and viewer accounts in a staging Supabase project:

- Anonymous visitors: read only published, due content; no drafts, future content, applications, roles or audit logs. Episodes of unpublished programmes must stay private.
- Viewer: cannot insert content or assign their own role; can save only their own favourites and application.
- Pending applicant: cannot create any content. Approval/rejection requires an owner token.
- Developer: can create only permitted content and edit only owned records. Attempts through the REST API to change owner, publish without permission, edit someone else's programme or change roles must fail.
- Owner: can publish/review content, edit settings and permissions, and approve applications.
- Confirm image type and size limits; verify foreign-folder uploads fail.
- Confirm verification email, reset email, sign-out, refresh persistence, published programme/episode/article visibility, future publication, timezone conversion and YouTube playback with a real embeddable video.

Only call the backend production-ready after these checks pass. Empty states must not be mistaken for confirmed connectivity; connection failures display a message.

## Backup

Use Supabase project backups or a PostgreSQL dump of your public schema/data. Export Storage bucket files separately; database backups do not contain image binaries. Keep encrypted copies of backups under owner control and test restoring into a separate project. Save versioned copies of schema changes before applying future migrations. Uploaded media is public; account/application data is private under RLS.

