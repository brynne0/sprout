# Seedling 🌱

A personal project to track plant sowing, transplanting and harvesting.

- PWA
- Developed for mobile and desktop

## Tech Stack

- Frontend: Vue, TypeScript
- Backend: Supabase (PostgreSQL with Row Level Security)
- Auth: Supabase Auth (email magic link)
- Deployment: Vercel

## Screenshots

<img width="200" alt="No Plants Yet" src="https://github.com/user-attachments/assets/4c8701a0-f634-4fba-a59c-33a0abe8d0dd" />
<img width="200" alt="Catalogue" src="https://github.com/user-attachments/assets/99f6bc33-e185-44d4-84e2-7de2e5b7eb61" />
<img width="200" alt="Plant Details" src="https://github.com/user-attachments/assets/22e2f0f4-fa31-433d-9c3d-0103051d8f0d" />
<img width="200" alt="Your Garden Plant Tab" src="https://github.com/user-attachments/assets/9220cb9e-6dc2-474e-9d15-3ac20747d850" />
<img width="200" alt="Edit Plant" src="https://github.com/user-attachments/assets/9154b2df-a990-49ae-bc99-0a064ece64c1" />
<img width="200" alt="Plant Dialogue" src="https://github.com/user-attachments/assets/210cfa5c-27b4-417e-b5e0-fe856ba49259" />

## Deployment

https://growasprout.com/

## To run locally

Requires Docker and the [Supabase CLI](https://supabase.com/docs/guides/cli).

```sh
npm install
make dev
```

Create a `.env` with `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` from `supabase status`. Sign-in emails appear in Mailpit at http://127.0.0.1:54324.

`make dev` starts a local Supabase stack (applying `supabase/migrations/`) and the Vite dev server. Point `.env` at it with the values printed by `supabase status`:

```sh
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<publishable key>
```

Magic-link emails are caught locally by Mailpit at http://127.0.0.1:54324.

After changing the schema, regenerate types with `npm run gen:types`.
