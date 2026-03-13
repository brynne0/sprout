.PHONY: dev stop

dev:
	docker compose -f sprout-api/docker-compose.yaml up -d
	cd sprout-api && ./gradlew run &
	npm run dev

stop:
	docker compose -f sprout-api/docker-compose.yaml down
	@pkill -f "GradleWorkerMain" || true
