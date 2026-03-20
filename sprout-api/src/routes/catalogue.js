import pool from '../db.js'

export default async function catalogueRoutes(app) {
  app.get('/plant-types', async (_request, reply) => {
    const result = await pool.query('SELECT id, name, category_id FROM plant_types ORDER BY name')
    reply.send(result.rows)
  })

  app.get('/plant-types/:id', async (request, reply) => {
    const result = await pool.query('SELECT id, name, category_id FROM plant_types WHERE id = $1', [
      request.params.id,
    ])
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })

  app.get('/plant-types/:id/catalogue', async (request, reply) => {
    const result = await pool.query(
      `SELECT id, plant_type_id, variety, description, seed_to_harvest, sowing_to_transplant,
              position, spacing, hardiness, sowing_windows, harvest_windows, transplant_windows,
              harvest, source
       FROM plant_catalogue WHERE plant_type_id = $1 ORDER BY variety NULLS FIRST`,
      [request.params.id],
    )
    reply.send(result.rows)
  })

  app.get('/catalogue', async (_request, reply) => {
    const result = await pool.query(
      `SELECT pc.id, pt.name, pc.variety, pc.description, pc.position, pc.hardiness,
              pc.spacing, pc.harvest, pc.source, pc.seed_to_harvest, pc.sowing_to_transplant,
              pc.sowing_windows, pc.harvest_windows, pc.transplant_windows
       FROM plant_catalogue pc
       JOIN plant_types pt ON pt.id = pc.plant_type_id
       ORDER BY pt.name, pc.variety NULLS FIRST`,
    )
    reply.send(result.rows)
  })
}
