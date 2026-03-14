import pool from '../db.js'

export default async function plantRoutes(app) {
  const auth = { onRequest: [app.authenticate] }

  app.get('/plants', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(
      'SELECT * FROM plants WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    )
    reply.send(result.rows)
  })

  app.post('/plants', auth, async (request, reply) => {
    const userId = request.user.sub
    const { catalogId, sowDate, notes } = request.body
    const result = await pool.query(
      'INSERT INTO plants (user_id, catalog_id, sow_date, notes) VALUES ($1, $2, $3, $4) RETURNING *',
      [userId, catalogId, sowDate, notes]
    )
    reply.code(201).send(result.rows[0])
  })

  app.get('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(
      'SELECT * FROM plants WHERE id = $1 AND user_id = $2',
      [request.params.id, userId]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })

  app.put('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const { catalogId, sowDate, notes } = request.body
    const result = await pool.query(
      'UPDATE plants SET catalog_id = $1, sow_date = $2, notes = $3 WHERE id = $4 AND user_id = $5 RETURNING *',
      [catalogId, sowDate, notes, request.params.id, userId]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })

  app.delete('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    await pool.query(
      'DELETE FROM plants WHERE id = $1 AND user_id = $2',
      [request.params.id, userId]
    )
    reply.code(204).send()
  })
}
