.PHONY: dev stop

dev:
	docker compose up -d
	npm run generate
	cd sprout-api && npm start &
	npm run dev

stop:
	docker compose down
	@lsof -i :8080 -t | xargs kill 2>/dev/null || true
