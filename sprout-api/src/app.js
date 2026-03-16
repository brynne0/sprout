import 'dotenv/config'
import Fastify from 'fastify'
import cors from '@fastify/cors'
import jwt from '@fastify/jwt'
import { runner as migrate } from 'node-pg-migrate'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'
import authRoutes from './routes/auth.js'
import plantRoutes from './routes/plants.js'
import catalogueRoutes from './routes/catalogue.js'

const app = Fastify({ logger: true })

app.register(cors, { origin: 'http://localhost:5173' })

app.register(jwt, {
  secret: process.env.JWT_SECRET,
})

app.decorate('authenticate', async (request, reply) => {
  try {
    await request.jwtVerify()
  } catch (err) {
    reply.send(err)
  }
})

app.register(authRoutes, { prefix: '/auth' })
app.register(plantRoutes, { prefix: '/api' })
app.register(catalogueRoutes, { prefix: '/api' })

const start = async () => {
  try {
    await migrate({
      databaseUrl: process.env.DATABASE_URL,
      migrationsTable: 'migrations',
      dir: join(dirname(fileURLToPath(import.meta.url)), '../db/migrations'),
      direction: 'up',
    })
    app.listen({ port: process.env.PORT || 8080, host: '0.0.0.0' })
  } catch (err) {
    app.log.error(err)
    process.exit(1)
  }
}

start()
