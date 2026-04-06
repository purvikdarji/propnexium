# Stage 1: Build
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN mkdir -p /app/uploads/properties
COPY --from=build /app/target/*.jar app.jar
EXPOSE ${PORT:-8080}
HEALTHCHECK --interval=30s --timeout=10s \
  --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", \
  "java -Djava.security.egd=file:/dev/./urandom \
   -Dspring.profiles.active=prod \
   -Dserver.port=${PORT:-8080} \
   -jar app.jar"]
