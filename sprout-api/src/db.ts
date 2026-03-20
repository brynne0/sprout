import { Pool } from 'postgres'

const databaseUrl = Deno.env.get('DATABASE_URL')!
const isLocal = databaseUrl.includes('localhost')

const pool = new Pool(databaseUrl, 3, !isLocal)

export default pool

export async function query<T>(sql: string, args?: unknown[]): Promise<T[]> {
  const client = await pool.connect()
  try {
    const result = await client.queryObject<T>(sql, args)
    return result.rows
  } finally {
    client.release()
  }
}
