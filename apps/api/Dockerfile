FROM eclipse-temurin:17-jdk

# Maven wrapper needs unzip to extract the Maven distribution
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Maven wrapper and config first (changes rarely → cached layer)
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Download dependencies (cached unless pom.xml changes)
RUN chmod +x mvnw && ./mvnw dependency:go-offline -q

# Copy source code (changes most often → last layer)
COPY src/ src/

EXPOSE 8081

CMD ["./mvnw", "spring-boot:run"]
