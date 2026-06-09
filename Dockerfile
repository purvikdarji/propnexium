# ════════════════════════════════════════════════════════════════════════════
# PropNexium — Multi-stage Dockerfile
# Stage 1 : Maven build (dependency cache layer for fast rebuilds)
# Stage 2 : Lean JRE runtime image (Alpine)
# ════════════════════════════════════════════════════════════════════════════

# ── Stage 1: Build ───────────────────────────────────────────────────────────
FROM maven:3.9.4-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml first so dependency layer is cached independently of source.
# Rebuild only happens when pom.xml changes.
COPY pom.xml .
RUN mvn dependency:go-offline -B --no-transfer-progress

# Copy source and build (skip tests — they run in CI, not Docker build)
COPY src ./src
RUN mvn clean package -DskipTests -B --no-transfer-progress

# ── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="PropNexium Team"
LABEL description="PropNexium Real Estate Platform with Apache Kafka"
LABEL version="1.0.0"

WORKDIR /app

# Create upload directory (bind-mounted at runtime)
RUN mkdir -p /app/uploads/properties

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Health check via Spring Boot Actuator
HEALTHCHECK \
  --interval=30s \
  --timeout=10s \
  --start-period=90s \
  --retries=5 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

# ── JVM tuning ────────────────────────────────────────────────────────────────
# -Djava.security.egd   : faster SecureRandom on Linux (needed for Kafka SSL)
# -XX:+UseContainerSupport : respect Docker memory/CPU limits (JDK 17 default)
# -XX:MaxRAMPercentage  : use up to 75% of container RAM for heap
# -XX:+UseG1GC          : G1GC is best for mixed web + Kafka consumer workloads
# -Dspring.kafka.bootstrap-servers is overridden by SPRING_KAFKA_BOOTSTRAP_SERVERS env
ENTRYPOINT ["sh", "-c", \
  "java \
   -Djava.security.egd=file:/dev/./urandom \
   -XX:+UseContainerSupport \
   -XX:MaxRAMPercentage=75.0 \
   -XX:+UseG1GC \
   -XX:G1HeapRegionSize=16m \
   -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-prod} \
   -Dserver.port=${PORT:-8080} \
   -jar app.jar"]
