import oauth2Plugin from '@fastify/oauth2'
import pool from '../db.js'

export default async function authRoutes(app) {
  app.register(oauth2Plugin, {
    name: 'googleOAuth2',
    scope: ['openid', 'email', 'profile'],
    credentials: {
      client: {
        id: process.env.GOOGLE_CLIENT_ID,
        secret: process.env.GOOGLE_CLIENT_SECRET,
      },
      auth: oauth2Plugin.GOOGLE_CONFIGURATION,
    },
    startRedirectPath: '/google',
    callbackUri: `${process.env.BACKEND_URL}/auth/google/callback`,
  })

  app.get('/google/callback', async (request, reply) => {
    const { token } = await app.googleOAuth2.getAccessTokenFromAuthorizationCodeFlow(request)

    const userInfoRes = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
      headers: { Authorization: `Bearer ${token.access_token}` },
    })
    const userInfo = await userInfoRes.json()

    const result = await pool.query(
      `INSERT INTO users (email, google_id)
       VALUES ($1, $2)
       ON CONFLICT (google_id) DO UPDATE SET email = EXCLUDED.email
       RETURNING id`,
      [userInfo.email, userInfo.id]
    )

    const jwt = app.jwt.sign({ sub: result.rows[0].id })

    reply.redirect(`${process.env.FRONTEND_URL}/auth/callback?token=${jwt}`)
  })
}
