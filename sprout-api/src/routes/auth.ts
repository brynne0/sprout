import { Hono } from "hono";
import { sign } from "hono/jwt";
import { query } from "../db.ts";
import { jwt } from "hono/jwt";

export const authRoutes = new Hono();

export const authMiddleware = jwt({
  secret: Deno.env.get("JWT_SECRET")!,
  alg: "HS256",
});

authRoutes.get("/google", (c) => {
  const params = new URLSearchParams({
    client_id: Deno.env.get("GOOGLE_CLIENT_ID")!,
    redirect_uri: `${Deno.env.get("BACKEND_URL")}/auth/google/callback`,
    response_type: "code",
    scope: "openid email profile",
  });
  return c.redirect(`https://accounts.google.com/o/oauth2/v2/auth?${params}`);
});

authRoutes.get("/google/callback", async (c) => {
  const code = c.req.query("code")!;

  // Exchange code for Google access token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code,
      client_id: Deno.env.get("GOOGLE_CLIENT_ID")!,
      client_secret: Deno.env.get("GOOGLE_CLIENT_SECRET")!,
      redirect_uri: `${Deno.env.get("BACKEND_URL")}/auth/google/callback`,
      grant_type: "authorization_code",
    }),
  });
  const { access_token } = await tokenRes.json();

  // Fetch user info from Google
  const userInfoRes = await fetch(
    "https://www.googleapis.com/oauth2/v2/userinfo",
    {
      headers: { Authorization: `Bearer ${access_token}` },
    },
  );
  const userInfo = await userInfoRes.json();

  // Upsert user
  const rows = await query<{ id: string }>(
    `INSERT INTO users (email, google_id)
     VALUES ($1, $2)
     ON CONFLICT (google_id) DO UPDATE SET email = EXCLUDED.email
     RETURNING id`,
    [userInfo.email, userInfo.id],
  );

  // Sign your JWT and redirect to frontend
  const jwt = await sign(
    { sub: rows[0].id },
    Deno.env.get("JWT_SECRET")!,
    "HS256",
  );
  return c.redirect(
    `${Deno.env.get("FRONTEND_URL")}/auth/callback?token=${jwt}`,
  );
});
