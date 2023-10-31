## Ratings data service

### Maven build

* Install maven & run `mvn package`

### Gradle build

* Install gradle 6+ & run `gradle clean build`

### Docker Build
* install Docker
* Docker build `docker build -t <your initials>/spingboot .`
* Docker run `docker run -p 8080:8080 uts/spingboot`
* Note - if you see a Mongo DB connection error , open sr/main/resources/application.properties and change the mongodb connection url to point to the correct mongodb instance or locally run mongo db in docker
