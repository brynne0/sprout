.PHONY: dev stop

dev:
	docker compose up -d
	npm run generate
	cd sprout-api && deno task generate
	cd sprout-api && deno task dev &
	npm run dev

stop:
	docker compose down -v
	@lsof -i :8080 -t | xargs kill 2>/dev/null || true
