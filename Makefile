.PHONY: dev stop

dev:
	docker compose up -d
	export $(shell cat .env | xargs) && cd sprout-api && ./gradlew run &
	npm run dev

stop:
	docker compose down
	@lsof -i :8080 -t | xargs kill 2>/dev/null || true
