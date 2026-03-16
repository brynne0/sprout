import pool from '../db.js'

const PLANT_SELECT = `
  SELECT
    p.id,
    p.catalog_id,
    COALESCE(p.name_override, pc.name) AS name,
    p.variety,
    p.sow_date,
    p.notes,
    COALESCE(p.overrides->>'description', pc.description) AS description,
    COALESCE(p.overrides->>'position', pc.position) AS position,
    COALESCE(p.overrides->>'hardiness', pc.hardiness) AS hardiness,
    COALESCE(p.overrides->>'spacing', pc.spacing) AS spacing,
    COALESCE(p.overrides->>'seed_to_harvest', pc.seed_to_harvest) AS seed_to_harvest,
    COALESCE(p.overrides->>'sowing_to_transplant', pc.sowing_to_transplant) AS sowing_to_transplant,
    COALESCE(p.overrides->>'harvest', pc.harvest) AS harvest,
    COALESCE(p.overrides->'sowing_windows', pc.sowing_windows) AS sowing_windows,
    COALESCE(p.overrides->'harvest_windows', pc.harvest_windows) AS harvest_windows,
    COALESCE(p.overrides->'transplant_windows', pc.transplant_windows) AS transplant_windows
  FROM plants p
  LEFT JOIN plant_catalog pc ON pc.id = p.catalog_id`

export default async function plantRoutes(app) {
  const auth = { onRequest: [app.authenticate] }

  app.get('/plants', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(
      `${PLANT_SELECT} WHERE p.user_id = $1 ORDER BY p.created_at DESC`,
      [userId],
    )
    reply.send(result.rows)
  })

  app.post('/plants', auth, async (request, reply) => {
    const userId = request.user.sub
    const { catalog_id, sow_date, notes, name_override, variety, overrides } = request.body
    const result = await pool.query(
      `INSERT INTO plants (user_id, catalog_id, sow_date, notes, name_override, variety, overrides)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING id`,
      [
        userId, catalog_id ?? null, sow_date, notes ?? null,
        name_override ?? null, variety ?? null,
        overrides ? JSON.stringify(overrides) : null,
      ],
    )
    const inserted = await pool.query(
      `${PLANT_SELECT} WHERE p.id = $1`,
      [result.rows[0].id],
    )
    reply.code(201).send(inserted.rows[0])
  })

  app.get('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(
      `${PLANT_SELECT} WHERE p.id = $1 AND p.user_id = $2`,
      [request.params.id, userId],
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })

  app.put('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const { catalog_id, sow_date, notes, name_override, variety, overrides } = request.body
    const result = await pool.query(
      `UPDATE plants SET
         catalog_id = $1, sow_date = $2, notes = $3,
         name_override = $4, variety = $5, overrides = $6
       WHERE id = $7 AND user_id = $8
       RETURNING id`,
      [
        catalog_id ?? null, sow_date, notes ?? null,
        name_override ?? null, variety ?? null,
        overrides ? JSON.stringify(overrides) : null,
        request.params.id, userId,
      ],
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    const updated = await pool.query(
      `${PLANT_SELECT} WHERE p.id = $1`,
      [result.rows[0].id],
    )
    reply.send(updated.rows[0])
  })

  app.delete('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    await pool.query(
      'DELETE FROM plants WHERE id = $1 AND user_id = $2',
      [request.params.id, userId],
    )
    reply.code(204).send()
  })
}
