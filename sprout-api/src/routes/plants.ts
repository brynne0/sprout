import { Context, Hono } from 'hono'
import { query } from '../db.ts'
import { authMiddleware } from './auth.ts'

export const plantRoutes = new Hono()

function getUserId(c: Context): string {
  return (c.get('jwtPayload') as { sub: string }).sub
}

const PLANT_SELECT = `
  SELECT
    p.id,
    p.plant_type_id,
    p.catalogue_id,
    p.custom_variety,
    pt.name AS name,
    pt.icon,
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
    COALESCE(p.overrides->'suitability', to_jsonb(pc.suitability)) AS suitability,
    COALESCE(p.overrides->'sowing_windows', pc.sowing_windows) AS sowing_windows,
    COALESCE(p.overrides->'harvest_windows', pc.harvest_windows) AS harvest_windows,
    COALESCE(p.overrides->'transplant_windows', pc.transplant_windows) AS transplant_windows
    FROM plants p
  JOIN plant_types pt ON pt.id = p.plant_type_id
  LEFT JOIN plant_catalogue pc ON pc.id = p.catalogue_id`

plantRoutes.use('*', authMiddleware)

plantRoutes.get('/plants', async (c) => {
  const userId = getUserId(c)
  const rows = await query(
    `${PLANT_SELECT} WHERE p.user_id = $1 AND archived_at IS NULL
    ORDER BY p.created_at DESC`,
    [userId],
  )
  return c.json(rows)
})

plantRoutes.post('/plants', async (c) => {
  const userId = getUserId(c)
  const {
    plant_type_id,
    catalogue_id,
    custom_variety,
    sow_dates,
    transplant_dates,
    notes,
    overrides,
  } = await c.req.json()
  const rows = await query<{ id: string }>(
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
  const inserted = await query(`${PLANT_SELECT} WHERE p.id = $1`, [rows[0].id])
  return c.json(inserted[0], 201)
})

plantRoutes.get('/plants/:id', async (c) => {
  const userId = getUserId(c)
  const rows = await query(`${PLANT_SELECT} WHERE p.id = $1 AND p.user_id = $2`, [
    c.req.param('id'),
    userId,
  ])
  if (!rows[0]) return c.json({ error: 'Not found' }, 404)
  return c.json(rows[0])
})

plantRoutes.put('/plants/:id', async (c) => {
  const userId = getUserId(c)
  const {
    plant_type_id,
    catalogue_id,
    custom_variety,
    sow_dates,
    transplant_dates,
    notes,
    overrides,
  } = await c.req.json()
  const rows = await query<{ id: string }>(
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
      c.req.param('id'),
      userId,
    ],
  )
  if (!rows[0]) return c.json({ error: 'Not found' }, 404)
  const updated = await query(`${PLANT_SELECT} WHERE p.id = $1`, [rows[0].id])
  return c.json(updated[0])
})

plantRoutes.patch('/plants/:id/archive', async (c) => {
  const userId = getUserId(c)
  const rows = await query<{ id: string }>(
    'UPDATE plants SET archived_at = NOW() WHERE id = $1 AND user_id = $2 RETURNING *',
    [c.req.param('id'), userId],
  )
  if (!rows[0]) return c.json({ error: 'Not found' }, 404)
  const archived = await query(`${PLANT_SELECT} WHERE p.id = $1`, [rows[0].id])
  return c.json(archived[0])
})

plantRoutes.delete('/plants/:id', async (c) => {
  const userId = getUserId(c)
  await query('DELETE FROM plants WHERE id = $1 AND user_id = $2', [c.req.param('id'), userId])
  return c.body(null, 204)
})
