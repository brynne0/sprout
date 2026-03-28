import { assertEquals } from "@std/assert";
import { sign } from "hono/jwt";
import app from "./app.ts";
import { runMigrations } from "./migrate.ts";
import { query } from "./db.ts";
import pool from "./db.ts";

const JWT_SECRET = Deno.env.get("JWT_SECRET")!;
const FAKE_UUID = "a1b2c3d4-e5f6-7890-abcd-ef1234567890";

async function createTestUser(): Promise<string> {
  const rows = await query<{ id: string }>(
    "INSERT INTO users (email, google_id) VALUES ('test@example.com', 'google-test-id') ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id",
  );
  return rows[0].id;
}

async function authHeader(userId: string): Promise<Record<string, string>> {
  const token = await sign({ sub: userId }, JWT_SECRET, "HS256");
  return { Authorization: `Bearer ${token}` };
}

await runMigrations();

// Catalogue routes
Deno.test("GET /api/plant-types returns 401 without auth", async () => {
  const res = await app.request("/api/plant-types");
  assertEquals(res.status, 401);
});

Deno.test("GET /api/plant-types returns 200 with auth", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const res = await app.request("/api/plant-types", { headers });
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(Array.isArray(body), true);
});

Deno.test("GET /api/plant-types/:id returns 404 for missing id", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const res = await app.request(`/api/plant-types/${FAKE_UUID}`, { headers });
  assertEquals(res.status, 404);
});

Deno.test("GET /api/catalogue returns 401 without auth", async () => {
  const res = await app.request("/api/catalogue");
  assertEquals(res.status, 401);
});

Deno.test("GET /api/catalogue returns 200 with auth", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const res = await app.request("/api/catalogue", { headers });
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(Array.isArray(body), true);
});

// Plant routes
Deno.test("GET /api/plants returns 401 without auth", async () => {
  const res = await app.request("/api/plants");
  assertEquals(res.status, 401);
});

Deno.test("GET /api/plants returns 200 with auth", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const res = await app.request("/api/plants", { headers });
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(Array.isArray(body), true);
});

Deno.test("POST /api/plants returns 401 without auth", async () => {
  const res = await app.request("/api/plants", { method: "POST" });
  assertEquals(res.status, 401);
});

Deno.test("GET /api/plants/:id returns 404 for missing plant", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const res = await app.request(`/api/plants/${FAKE_UUID}`, { headers });
  assertEquals(res.status, 404);
});

Deno.test("DELETE /api/plants/:id returns 204", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const res = await app.request(`/api/plants/${FAKE_UUID}`, {
    method: "DELETE",
    headers,
  });
  assertEquals(res.status, 204);
});

Deno.test("POST /api/plants creates a plant and returns 201", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const res = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  assertEquals(res.status, 201);
  const body = await res.json();
  assertEquals(body.plant_type_id, plantType!.id);
});

Deno.test("GET /api/plants/:id returns plant with category_name", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const created = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  const { id } = await created.json();
  const res = await app.request(`/api/plants/${id}`, { headers });
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(typeof body.category_name, "string");
});

Deno.test("PUT /api/plants/:id updates a plant", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const created = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  const { id } = await created.json();
  const res = await app.request(`/api/plants/${id}`, {
    method: "PUT",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id, notes: "updated" }),
  });
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(body.notes, "updated");
});

Deno.test("PATCH /api/plants/:id/archive archives a plant", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const created = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  const { id } = await created.json();
  const archiveRes = await app.request(`/api/plants/${id}/archive`, {
    method: "PATCH",
    headers,
  });
  assertEquals(archiveRes.status, 200);
  // Archived plant should not appear in GET /api/plants
  const listRes = await app.request("/api/plants", { headers });
  const plants = await listRes.json();
  assertEquals(plants.some((p: { id: string }) => p.id === id), false);
});

Deno.test("POST /api/plants with overrides returns overridden values", async () => {
  const userId = await createTestUser();
  const headers = await authHeader(userId);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const res = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({
      plant_type_id: plantType!.id,
      overrides: { description: "my custom description" },
    }),
  });
  assertEquals(res.status, 201);
  const body = await res.json();
  assertEquals(body.description, "my custom description");
});

// Ownership tests
Deno.test("GET /api/plants/:id returns 404 for another user's plant", async () => {
  const userA = await createTestUser();
  const userB = await query<{ id: string }>(
    "INSERT INTO users (email, google_id) VALUES ('other@example.com', 'google-other-id') ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id",
  ).then((r) => r[0].id);
  const headersA = await authHeader(userA);
  const headersB = await authHeader(userB);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const created = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headersA, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  const { id } = await created.json();
  const res = await app.request(`/api/plants/${id}`, { headers: headersB });
  assertEquals(res.status, 404);
});

Deno.test("PUT /api/plants/:id returns 404 for another user's plant", async () => {
  const userA = await createTestUser();
  const userB = await query<{ id: string }>(
    "INSERT INTO users (email, google_id) VALUES ('other@example.com', 'google-other-id') ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id",
  ).then((r) => r[0].id);
  const headersA = await authHeader(userA);
  const headersB = await authHeader(userB);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const created = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headersA, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  const { id } = await created.json();
  const res = await app.request(`/api/plants/${id}`, {
    method: "PUT",
    headers: { ...headersB, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  assertEquals(res.status, 404);
});

Deno.test("PATCH /api/plants/:id/archive returns 404 for another user's plant", async () => {
  const userA = await createTestUser();
  const userB = await query<{ id: string }>(
    "INSERT INTO users (email, google_id) VALUES ('other@example.com', 'google-other-id') ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id",
  ).then((r) => r[0].id);
  const headersA = await authHeader(userA);
  const headersB = await authHeader(userB);
  const [plantType] = await query<{ id: string }>(
    "SELECT id FROM plant_types LIMIT 1",
  );
  const created = await app.request("/api/plants", {
    method: "POST",
    headers: { ...headersA, "Content-Type": "application/json" },
    body: JSON.stringify({ plant_type_id: plantType!.id }),
  });
  const { id } = await created.json();
  const res = await app.request(`/api/plants/${id}/archive`, {
    method: "PATCH",
    headers: headersB,
  });
  assertEquals(res.status, 404);
});

// Auth routes
Deno.test("GET /auth/google redirects to Google", async () => {
  const res = await app.request("/auth/google", { redirect: "manual" });
  assertEquals(res.status, 302);
  const location = res.headers.get("Location")!;
  assertEquals(location.includes("accounts.google.com"), true);
});

Deno.test("expired JWT returns 401", async () => {
  const userId = await createTestUser();
  const expiredToken = await sign(
    { sub: userId, exp: Math.floor(Date.now() / 1000) - 1 },
    JWT_SECRET,
    "HS256",
  );
  const res = await app.request("/api/plants", {
    headers: { Authorization: `Bearer ${expiredToken}` },
  });
  assertEquals(res.status, 401);
});

// Clean up database connection pool
Deno.test({
  name: "cleanup",
  fn: async () => {
    await pool.end();
  },
  sanitizeOps: false,
  sanitizeResources: false,
});
