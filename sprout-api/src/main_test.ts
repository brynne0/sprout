import { assertEquals } from '@std/assert'
import { sign } from 'hono/jwt'
import app from './app.ts'
import { runMigrations } from './migrate.ts'
import { query } from './db.ts'
import pool from './db.ts'

const JWT_SECRET = Deno.env.get('JWT_SECRET')!
const FAKE_UUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

async function createTestUser(): Promise<string> {
  const rows = await query<{ id: string }>(
    "INSERT INTO users (email, google_id) VALUES ('test@example.com', 'google-test-id') ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id",
  )
  return rows[0].id
}

async function authHeader(userId: string): Promise<Record<string, string>> {
  const token = await sign({ sub: userId }, JWT_SECRET, 'HS256')
  return { Authorization: `Bearer ${token}` }
}

await runMigrations()

// Catalogue routes
Deno.test('GET /api/plant-types returns 401 without auth', async () => {
  const res = await app.request('/api/plant-types')
  assertEquals(res.status, 401)
})

Deno.test('GET /api/plant-types returns 200 with auth', async () => {
  const userId = await createTestUser()
  const headers = await authHeader(userId)
  const res = await app.request('/api/plant-types', { headers })
  assertEquals(res.status, 200)
  const body = await res.json()
  assertEquals(Array.isArray(body), true)
})

Deno.test('GET /api/plant-types/:id returns 404 for missing id', async () => {
  const userId = await createTestUser()
  const headers = await authHeader(userId)
  const res = await app.request(`/api/plant-types/${FAKE_UUID}`, { headers })
  assertEquals(res.status, 404)
})

Deno.test('GET /api/catalogue returns 401 without auth', async () => {
  const res = await app.request('/api/catalogue')
  assertEquals(res.status, 401)
})

Deno.test('GET /api/catalogue returns 200 with auth', async () => {
  const userId = await createTestUser()
  const headers = await authHeader(userId)
  const res = await app.request('/api/catalogue', { headers })
  assertEquals(res.status, 200)
  const body = await res.json()
  assertEquals(Array.isArray(body), true)
})

// Plant routes
Deno.test('GET /api/plants returns 401 without auth', async () => {
  const res = await app.request('/api/plants')
  assertEquals(res.status, 401)
})

Deno.test('GET /api/plants returns 200 with auth', async () => {
  const userId = await createTestUser()
  const headers = await authHeader(userId)
  const res = await app.request('/api/plants', { headers })
  assertEquals(res.status, 200)
  const body = await res.json()
  assertEquals(Array.isArray(body), true)
})

Deno.test('POST /api/plants returns 401 without auth', async () => {
  const res = await app.request('/api/plants', { method: 'POST' })
  assertEquals(res.status, 401)
})

Deno.test('GET /api/plants/:id returns 404 for missing plant', async () => {
  const userId = await createTestUser()
  const headers = await authHeader(userId)
  const res = await app.request(`/api/plants/${FAKE_UUID}`, { headers })
  assertEquals(res.status, 404)
})

Deno.test('DELETE /api/plants/:id returns 204', async () => {
  const userId = await createTestUser()
  const headers = await authHeader(userId)
  const res = await app.request(`/api/plants/${FAKE_UUID}`, {
    method: 'DELETE',
    headers,
  })
  assertEquals(res.status, 204)
})

// Auth routes
Deno.test('GET /auth/google redirects to Google', async () => {
  const res = await app.request('/auth/google', { redirect: 'manual' })
  assertEquals(res.status, 302)
  const location = res.headers.get('Location')!
  assertEquals(location.includes('accounts.google.com'), true)
})

// Clean up database connection pool
Deno.test({
  name: 'cleanup',
  fn: async () => {
    await pool.end()
  },
  sanitizeOps: false,
  sanitizeResources: false,
})
