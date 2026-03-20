import '@std/dotenv/load'
import { runMigrations } from './migrate.ts'
import app from './app.ts'

await runMigrations()

Deno.serve({ port: Number(Deno.env.get('PORT') ?? 8080) }, app.fetch)
