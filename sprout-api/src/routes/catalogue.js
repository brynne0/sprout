import pool from '../db.js'

const CATALOGUE_SELECT = `
  SELECT
    id,
    name,
    variety,
    description,
    position,
    hardiness,
    spacing,
    harvest,
    source,
    seed_to_harvest,
    sowing_to_transplant,
    sowing_windows,
    harvest_windows,
    transplant_windows
  FROM plant_catalogue
`

export default async function catalogRoutes(app) {
  app.get('/catalogue', async (_request, reply) => {
    const result = await pool.query(`${CATALOGUE_SELECT} ORDER BY name`)
    reply.send(result.rows)
  })

  app.get('/catalogue/:id', async (request, reply) => {
    const result = await pool.query(`${CATALOGUE_SELECT} WHERE id = $1`, [request.params.id])
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })
}
