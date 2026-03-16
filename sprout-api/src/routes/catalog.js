import pool from '../db.js'

const CATALOG_SELECT = `
  SELECT
    id,
    name,
    description,
    position,
    hardiness,
    spacing,
    harvest,
    source,
    seed_to_harvest        AS "seedToHarvest",
    sowing_to_transplant   AS "sowingToTransplant",
    sowing_windows         AS "sowingWindows",
    harvest_windows        AS "harvestWindows",
    transplant_windows     AS "transplantWindows"
  FROM plant_catalog
`

export default async function catalogRoutes(app) {
  app.get('/catalog', async (_request, reply) => {
    const result = await pool.query(`${CATALOG_SELECT} ORDER BY name`)
    reply.send(result.rows)
  })

  app.get('/catalog/:id', async (request, reply) => {
    const result = await pool.query(
      `${CATALOG_SELECT} WHERE id = $1`,
      [request.params.id]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })
}
