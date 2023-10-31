#################### USING MAVEN BUILD ################
FROM public.ecr.aws/docker/library/maven:3.6.3-amazoncorretto as build-env

VOLUME /tmp
WORKDIR /

COPY ./pom.xml .

RUN mvn dependency:go-offline -B

COPY ./src ./src

RUN mvn package
RUN ls
RUN mv ./target/*.jar /*.jar

#################### Package Stage ################
FROM openjdk:11-jre

#ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/download/v0.18.0-aws.1/aws-opentelemetry-agent.jar /app/aws-opentelemetry-agent.jar
#ENV JAVA_TOOL_OPTIONS "-javaagent:/app/aws-opentelemetry-agent.jar"


#RUN apt-get update -y
#
#RUN apt-get install jq -y
#
#COPY entrypoint.sh /app/
#RUN chmod +x /app/entrypoint.sh


WORKDIR /app

COPY --from=build-env /*.jar service.jar


#ENV OTEL_RESOURCE_ATTRIBUTES "service.name=RatingService"
#ENV OTEL_IMR_EXPORT_INTERVAL "10000"
#ENV OTEL_EXPORTER_OTLP_ENDPOINT "http://localhost:55680"


ENTRYPOINT exec java -jar service.jar
#ENTRYPOINT ["/app/entrypoint.sh"]
