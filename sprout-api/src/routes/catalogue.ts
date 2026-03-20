import { Hono } from 'hono'
import { query } from '../db.ts'

export const catalogueRoutes = new Hono()

catalogueRoutes.get('/plant-types', async (c) => {
  const rows = await query('SELECT id, name, category_id FROM plant_types ORDER BY name')
  return c.json(rows)
})

catalogueRoutes.get('/plant-types/:id', async (c) => {
  const rows = await query('SELECT id, name, category_id FROM plant_types WHERE id = $1', [
    c.req.param('id'),
  ])
  if (!rows[0]) return c.json({ error: 'Not found' }, 404)
  return c.json(rows[0])
})

catalogueRoutes.get('/plant-types/:id/catalogue', async (c) => {
  const rows = await query(
    `SELECT id, plant_type_id, variety, description, seed_to_harvest, sowing_to_transplant,
              position, spacing, hardiness, sowing_windows, harvest_windows, transplant_windows,
              harvest, source
       FROM plant_catalogue WHERE plant_type_id = $1 ORDER BY variety NULLS FIRST`,
    [c.req.param('id')],
  )
  return c.json(rows)
})

catalogueRoutes.get('/catalogue', async (c) => {
  const rows = await query(
    `SELECT pc.id, pt.name, pc.variety, pc.description, pc.position, pc.hardiness,
              pc.spacing, pc.harvest, pc.source, pc.seed_to_harvest, pc.sowing_to_transplant,
              pc.sowing_windows, pc.harvest_windows, pc.transplant_windows
       FROM plant_catalogue pc
       JOIN plant_types pt ON pt.id = pc.plant_type_id
       ORDER BY pt.name, pc.variety NULLS FIRST`,
  )
  return c.json(rows)
})
