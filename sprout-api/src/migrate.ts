import pool from "./db.ts";

export async function runMigrations() {
  const client = await pool.connect();
  try {
    await client.queryObject(`
      CREATE TABLE IF NOT EXISTS migrations (
        name TEXT PRIMARY KEY,
        ran_at TIMESTAMPTZ DEFAULT now()
      )
    `);
    const entries = [...Deno.readDirSync("./db/migrations")].sort((a, b) =>
      a.name.localeCompare(b.name)
    );
    for (const entry of entries) {
      const { rows } = await client.queryObject(
        "SELECT 1 FROM migrations WHERE name = $1",
        [
          entry.name,
        ],
      );

      if (rows.length > 0) {
        console.log(`Skipping ${entry.name} (already applied)`);
        continue;
      }

      console.log(`Applying ${entry.name}...`);
      const sql = await Deno.readTextFile(`./db/migrations/${entry.name}`);
      await client.queryObject(sql);
      await client.queryObject("INSERT INTO migrations (name) VALUES ($1)", [
        entry.name,
      ]);
    }
  } finally {
    client.release();
  }
}
