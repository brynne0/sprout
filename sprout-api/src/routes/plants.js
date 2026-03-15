import pool from '../db.js'

export default async function plantRoutes(app) {
  const auth = { onRequest: [app.authenticate] }

  app.get('/plants', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(
      `SELECT
          p.id,
          p.catalog_id AS "catalogId",
          COALESCE(p.name_override, pc.name) AS name,
          p.variety,
          p.sow_date AS "sowDate",
          p.notes,
          COALESCE(p.sowing_windows_override, pc.sowing_windows) AS "sowingWindows",
          COALESCE(p.harvest_windows_override, pc.harvest_windows) AS "harvestWindows",
          COALESCE(p.transplant_windows_override, pc.transplant_windows) AS "transplantWindows"
        FROM plants p
        LEFT JOIN plant_catalog pc ON pc.id = p.catalog_id   -- LEFT JOIN (catalog_id may be null)
        WHERE p.user_id = $1
        ORDER BY p.created_at DESC`,
      [userId],
    )
    reply.send(result.rows)
  })

  app.post('/plants', auth, async (request, reply) => {
    const userId = request.user.sub
    const {
      catalogId, sowDate, notes,
      nameOverride, variety,
      sowingWindowsOverride, harvestWindowsOverride, transplantWindowsOverride
    } = request.body
    const result = await pool.query(
      `INSERT INTO plants
         (user_id, catalog_id, sow_date, notes, name_override, variety,
          sowing_windows_override, harvest_windows_override, transplant_windows_override)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       RETURNING *`,
      [
        userId, catalogId ?? null, sowDate, notes ?? null,
        nameOverride ?? null, variety ?? null,
        sowingWindowsOverride ? JSON.stringify(sowingWindowsOverride) : null,
        harvestWindowsOverride ? JSON.stringify(harvestWindowsOverride) : null,
        transplantWindowsOverride ? JSON.stringify(transplantWindowsOverride) : null
      ]
    )
    reply.code(201).send(result.rows[0])
  })

  app.get('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const result = await pool.query(
      `SELECT
         p.id,
         p.catalog_id AS "catalogId",
         COALESCE(p.name_override, pc.name) AS name,
         p.variety,
         p.sow_date AS "sowDate",
         p.notes,
         COALESCE(p.sowing_windows_override, pc.sowing_windows) AS "sowingWindows",
         COALESCE(p.harvest_windows_override, pc.harvest_windows) AS "harvestWindows",
         COALESCE(p.transplant_windows_override, pc.transplant_windows) AS "transplantWindows"
       FROM plants p
       LEFT JOIN plant_catalog pc ON pc.id = p.catalog_id
       WHERE p.id = $1 AND p.user_id = $2`,
      [request.params.id, userId]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
  })

  app.put('/plants/:id', auth, async (request, reply) => {
    const userId = request.user.sub
    const {
      catalogId, sowDate, notes,
      nameOverride, variety,
      sowingWindowsOverride, harvestWindowsOverride, transplantWindowsOverride
    } = request.body
    const result = await pool.query(
      `UPDATE plants SET
         catalog_id = $1,
         sow_date = $2,
         notes = $3,
         name_override = $4,
         variety = $5,
         sowing_windows_override = $6,
         harvest_windows_override = $7,
         transplant_windows_override = $8
       WHERE id = $9 AND user_id = $10
       RETURNING *`,
      [
        catalogId ?? null, sowDate, notes ?? null,
        nameOverride ?? null, variety ?? null,
        sowingWindowsOverride ? JSON.stringify(sowingWindowsOverride) : null,
        harvestWindowsOverride ? JSON.stringify(harvestWindowsOverride) : null,
        transplantWindowsOverride ? JSON.stringify(transplantWindowsOverride) : null,
        request.params.id, userId
      ]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    reply.send(result.rows[0])
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
