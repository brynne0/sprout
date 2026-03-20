import pool from '../db.js'

const PLANT_SELECT = `
  SELECT
    p.id,
    p.plant_type_id,
    p.catalogue_id,
    p.custom_variety,
    pt.name AS name,
    COALESCE(pc.variety, p.custom_variety) AS variety,
    p.sow_dates,
    p.transplant_dates,
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
  JOIN plant_types pt ON pt.id = p.plant_type_id
  LEFT JOIN plant_catalogue pc ON pc.id = p.catalogue_id`

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
    const { plant_type_id, catalogue_id, custom_variety, sow_dates, transplant_dates, notes, overrides } = request.body
    const result = await pool.query(
      `INSERT INTO plants (user_id, plant_type_id, catalogue_id, custom_variety, sow_dates, transplant_dates, notes, overrides)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       RETURNING id`,
      [
        userId,
        plant_type_id,
        catalogue_id ?? null,
        custom_variety ?? null,
        sow_dates ?? [],
        transplant_dates ?? [],
        notes ?? null,
        overrides ? JSON.stringify(overrides) : null,
      ],
    )
    const inserted = await pool.query(`${PLANT_SELECT} WHERE p.id = $1`, [result.rows[0].id])
    reply.code(201).send(inserted.rows[0])
  })

  app.get('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(`${PLANT_SELECT} WHERE p.id = $1 AND p.user_id = $2`, [
      request.params.id,
      userId,
    ])
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })

  app.put('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const { plant_type_id, catalogue_id, custom_variety, sow_dates, transplant_dates, notes, overrides } = request.body
    const result = await pool.query(
      `UPDATE plants SET
         plant_type_id = $1, catalogue_id = $2, custom_variety = $3,
         sow_dates = $4, transplant_dates = $5, notes = $6, overrides = $7
       WHERE id = $8 AND user_id = $9
       RETURNING id`,
      [
        plant_type_id,
        catalogue_id ?? null,
        custom_variety ?? null,
        sow_dates ?? [],
        transplant_dates ?? [],
        notes ?? null,
        overrides ? JSON.stringify(overrides) : null,
        request.params.id,
        userId,
      ],
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    const updated = await pool.query(`${PLANT_SELECT} WHERE p.id = $1`, [result.rows[0].id])
    reply.send(updated.rows[0])
  })

  app.delete('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    await pool.query('DELETE FROM plants WHERE id = $1 AND user_id = $2', [
      request.params.id,
      userId,
    ])
    reply.code(204).send()
  })
}
