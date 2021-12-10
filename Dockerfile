FROM ubuntu:latest as stage1
LABEL maintainer="John Burt"

ENV DEBIAN_FRONTEND=noninteractive
ARG VERSION=1.3.0

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev wget maven default-jdk gpg
RUN \
 wget https://archive.apache.org/dist/guacamole/${VERSION}/source/guacamole-client-${VERSION}.tar.gz && \
 wget https://archive.apache.org/dist/guacamole/1.3.0/source/guacamole-client-${VERSION}.tar.gz.asc && \
 wget https://downloads.apache.org/guacamole/KEYS && \
 gpg --import ./KEYS && \
 gpg --verify guacamole-client-${VERSION}.tar.gz.asc guacamole-client-${VERSION}.tar.gz &&\
 tar -xzf guacamole-client-${VERSION}.tar.gz && \
 cd guacamole-client-${VERSION}/ && \
 export JAVA_HOME=$(realpath /usr/bin/javadoc | sed 's@bin/javadoc$@@') && \
 mvn clean package -Plgpl-extensions && \
 mkdir /output && \
 find "/guacamole-client-${VERSION}/extensions/" -name "guacamole-*.jar" -exec cp {} /output \; && \
 ls /output


FROM guacamole/guacamole:latest

COPY --from=stage1 /output/* /extensions/

# Start Guacamole under Tomcat, listening on 0.0.0.0:8080
EXPOSE 8080
CMD ["/opt/guacamole/bin/start.sh" ]