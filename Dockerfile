FROM openjdk:17-jdk-alpine
COPY target/springboot-demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8484
ENTRYPOINT ["java", "-jar", "/app.jar", "--server.port=8484"]
