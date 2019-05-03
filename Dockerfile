FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-Xms128m","-Xmx256m","-Dspring.profiles.active=prod","-cp","app:app/lib/*","de.archilab.coalbase.servicediscovery.ServiceDiscoveryApplication"]
