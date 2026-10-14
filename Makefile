.PHONY: dev stop

dev:
	supabase start
	npm run dev

stop:
	supabase stop
