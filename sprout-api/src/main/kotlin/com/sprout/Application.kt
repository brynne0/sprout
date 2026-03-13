package com.sprout

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.cio.CIO as ClientCIO
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation as ClientContentNegotiation
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.cio.*
import io.ktor.server.engine.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import org.flywaydb.core.Flyway

@Serializable
data class GoogleUserInfo(
    val id: String,
    val email: String,
    val name: String? = null,
)

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

    val jwtSecret = System.getenv("JWT_SECRET")
    val algorithm = Algorithm.HMAC256(jwtSecret)
    val googleClientId = System.getenv("GOOGLE_CLIENT_ID")
    val googleClientSecret = System.getenv("GOOGLE_CLIENT_SECRET")
    val frontendUrl = System.getenv("FRONTEND_URL")

    val json = Json { ignoreUnknownKeys = true }

    val httpClient = HttpClient(ClientCIO) {
        install(ClientContentNegotiation) {
            json(json)
        }
    }

    embeddedServer(CIO, port = 8080) {
        install(ContentNegotiation) {
            json()
        }

        install(Authentication) {
            oauth("google-oauth") {
                urlProvider = { "http://localhost:8080/auth/google/callback" }
                providerLookup = {
                    OAuthServerSettings.OAuth2ServerSettings(
                        name = "google",
                        authorizeUrl = "https://accounts.google.com/o/oauth2/auth",
                        accessTokenUrl = "https://oauth2.googleapis.com/token",
                        requestMethod = HttpMethod.Post,
                        clientId = googleClientId,
                        clientSecret = googleClientSecret,
                        defaultScopes = listOf("openid", "email", "profile"),
                    )
                }
                client = httpClient
            }

            jwt("auth-jwt") {
                realm = "sprout"
                verifier(JWT.require(algorithm).build())
                validate { credential ->
                    JWTPrincipal(credential.payload)
                }
            }
        }

        routing {
            authenticate("google-oauth") {
                get("/auth/google") { /* Redirect to Google automatically */ }

                get("/auth/google/callback") {
                    val principal = call.principal<OAuthAccessTokenResponse.OAuth2>()
                        ?: return@get call.respond(HttpStatusCode.Unauthorized)

                    val userInfo = httpClient.get("https://www.googleapis.com/oauth2/v2/userinfo") {
                        headers {
                            append(HttpHeaders.Authorization, "Bearer ${principal.accessToken}")
                        }
                    }.body<GoogleUserInfo>()

                    val userId = dataSource.connection.use { conn ->
                        conn.prepareStatement(
                            """
                            INSERT INTO users (id, email, name) VALUES (gen_random_uuid(), ?, ?)
                            ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name
                            RETURNING id
                            """.trimIndent()
                        ).use { stmt ->
                            stmt.setString(1, userInfo.email)
                            stmt.setString(2, userInfo.name)
                            val rs = stmt.executeQuery()
                            rs.next()
                            rs.getString("id")
                        }
                    }

                    val token = JWT.create()
                        .withSubject(userId)
                        .sign(algorithm)

                    call.respondRedirect("$frontendUrl/auth/callback?token=$token")
                }
            }

            authenticate("auth-jwt") {
                get("/api/plants") {
                    call.respondText("ok")
                }
            }
        }
    }.start(wait = true)
}
