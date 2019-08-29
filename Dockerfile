FROM openjdk:8u212-jdk-alpine3.9

ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java","-Xms128m","-Xmx256m","-Dspring.profiles.active=prod","-cp","app:app/lib/*","de.archilab.coalbase.servicediscovery.ServiceDiscoveryApplication"]
