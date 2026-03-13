plugins {
    kotlin("jvm") version "2.0.21"
    id("io.ktor.plugin") version "3.1.1"
    application
}

application {
    mainClass.set("com.sprout.ApplicationKt")
}

repositories {
    mavenCentral()
}

dependencies {
    // Ktor
    implementation("io.ktor:ktor-server-core")
    implementation("io.ktor:ktor-server-cio")
    implementation("io.ktor:ktor-server-content-negotiation")
    implementation("io.ktor:ktor-serialization-kotlinx-json")

    // Database
    implementation("org.flywaydb:flyway-core:10.20.1")
    implementation("org.flywaydb:flyway-database-postgresql:10.20.1")
    implementation("org.postgresql:postgresql:42.7.4")
    implementation("com.zaxxer:HikariCP:6.2.1")

    // Logging
    implementation("ch.qos.logback:logback-classic:1.5.12")
}
