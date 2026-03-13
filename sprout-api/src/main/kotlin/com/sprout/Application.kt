package com.sprout

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.server.application.*
import io.ktor.server.cio.*
import io.ktor.server.engine.*
import org.flywaydb.core.Flyway
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import com.auth0.jwk.JwkProviderBuilder
import io.ktor.server.routing.*
import io.ktor.server.response.*
import io.ktor.http.*



fun main() {
    val dataSource = HikariDataSource(HikariConfig().apply {
        jdbcUrl = System.getenv("DB_URL") 
        username = System.getenv("DB_USER") 
        password = System.getenv("DB_PASSWORD") 
    })

    Flyway.configure()
        .dataSource(dataSource)
        .load()
        .migrate()

    val keycloakUrl = System.getenv("KEYCLOAK_URL")

    embeddedServer(CIO, port = 8080) {
        install(Authentication) {
            jwt("auth-jwt") {
                realm = "sprout"
                verifier(
                    jwkProvider = JwkProviderBuilder("$keycloakUrl/realms/sprout/protocol/openid-connect/certs").build(),
                    issuer = "$keycloakUrl/realms/sprout"
                )
                validate { credential ->
                    // return a Principal if valid, null to reject
                    JWTPrincipal(credential.payload)
                }
            }
        }
        routing {
            authenticate("auth-jwt") {
                get("/api/plants") {
                    call.respondText("ok")
                }
            }
}


    }.start(wait = true)
}
