import pool from '../db.js'

export default async function catalogRoutes(app) {
  app.get('/catalog', async (request, reply) => {
    const result = await pool.query('SELECT * FROM plant_catalog ORDER BY name')
    reply.send(result.rows)
  })

  app.get('/catalog/:id', async (request, reply) => {
    const result = await pool.query(
      'SELECT * FROM plant_catalog WHERE id = $1',
      [request.params.id]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })
}
