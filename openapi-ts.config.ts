import { defineConfig } from '@hey-api/openapi-ts'

export default defineConfig({
  input: './sprout-api/oas.yaml',
  output: './src/client',
  plugins: ['@hey-api/client-fetch'],
})
