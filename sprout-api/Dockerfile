FROM denoland/deno:latest

WORKDIR /app

COPY deno.json deno.lock* ./
RUN deno install

COPY . .

EXPOSE 8080

CMD ["deno", "task", "start"]
