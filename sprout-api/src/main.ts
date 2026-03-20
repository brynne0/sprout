import '@std/dotenv/load'
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { authRoutes } from './routes/auth.ts'
import { plantRoutes } from './routes/plants.ts'
import { catalogueRoutes } from './routes/catalogue.ts'
import { runMigrations } from './migrate.ts'

const app = new Hono()

app.use('*', cors({ origin: Deno.env.get('FRONTEND_URL')! }))

app.route('/auth', authRoutes)
app.route('/api', plantRoutes)
app.route('/api', catalogueRoutes)

await runMigrations()

Deno.serve({ port: Number(Deno.env.get('PORT') ?? 8080) }, app.fetch)
