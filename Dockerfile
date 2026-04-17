FROM openjdk:11-ea-17-jre-slim

# Add application metadata
LABEL maintainer="Chaitanya"
LABEL application="Simple Spring Boot App"

# Set working directory
WORKDIR /app

# Copy only the built JAR from the build stage
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

# Expose the application port
EXPOSE 5600

# Set entry point
ENTRYPOINT ["java", "-jar", "app.jar"]