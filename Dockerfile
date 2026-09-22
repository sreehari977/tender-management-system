# Multi-stage Docker build for Tender Management System
# Stage 1: Build the WAR using Maven and Eclipse Temurin JDK 17
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and source code
COPY pom.xml .
COPY src ./src

# Package WAR file
RUN mvn clean package -DskipTests

# Stage 2: Deploy to Apache Tomcat 10.1 (Jakarta EE 10)
FROM tomcat:10.1-jdk17-temurin

# Clean out default Tomcat sample webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy as ROOT application so URL is https://your-domain.com/
COPY --from=build /app/target/TenderManagementSystem.war /usr/local/tomcat/webapps/ROOT.war

# Expose standard Tomcat port
EXPOSE 8080

# Start Tomcat in foreground
CMD ["catalina.sh", "run"]
