package com.sprout

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.server.application.*
import io.ktor.server.cio.*
import io.ktor.server.engine.*
import org.flywaydb.core.Flyway

fun main() {
    val dataSource = HikariDataSource(HikariConfig().apply {
        jdbcUrl = "jdbc:postgresql://localhost:5432/sprout"
        username = "sprout"
        password = "sprout"
    })

    Flyway.configure()
        .dataSource(dataSource)
        .load()
        .migrate()

    embeddedServer(CIO, port = 8080) {
        // routes go here later
    }.start(wait = true)
}
