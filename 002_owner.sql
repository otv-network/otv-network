-- First sign up on OTV and verify your email.
-- Run this ONLY in the Supabase SQL editor, signed in as the project owner.
-- Replace the email below with your verified account email. No browser endpoint can bootstrap an admin.
insert into public.roles(user_id,role,permissions)
select id,'admin','{}'::jsonb from auth.users
where lower(email)=lower('REPLACE_WITH_YOUR_VERIFIED_EMAIL') and email_confirmed_at is not null
on conflict(user_id) do update set role='admin';
-- Confirm exactly your intended account was added:
select u.email,r.role from public.roles r join auth.users u on u.id=r.user_id where r.role='admin';
