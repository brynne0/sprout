import 'dotenv/config'
import Fastify from 'fastify'
import jwt from '@fastify/jwt'
import authRoutes from './routes/auth.js'
import plantRoutes from './routes/plants.js'
import catalogRoutes from './routes/catalog.js'

const app = Fastify({ logger: true })

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
app.register(catalogRoutes, { prefix: '/api' })

const start = async () => {
  try {
    await app.listen({ port: process.env.PORT || 8080, host: '0.0.0.0' })
  } catch (err) {
    app.log.error(err)
    process.exit(1)
  }
}

start()
