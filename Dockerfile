FROM eclipse-temurin:8-jdk
COPY jarstaging/com/valaxy/demo-workshop/2.1.5/demo-workshop-2.1.5.jar ttrend.jar
ENTRYPOINT ["java", "-jar", "ttrend.jar"]