FROM anapsix/alpine-java:8u144b01_jdk_unlimited
MAINTAINER weixuedian <weixuedian@qq.com>

#tomcat 8 installed
ENV TOMCAT_MAJOR=8 \
    TOMCAT_VERSION=8.5.3 \
    TOMCAT_HOME=/opt/tomcat \
    CATALINA_HOME=/opt/tomcat \
    CATALINA_OUT=/dev/null \
    ENTRY_FILE=/opt/entry.sh
RUN apk upgrade --update && \
    apk add --update curl && \
    curl -jksSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME} && \
    rm -rf ${TOMCAT_HOME}/webapps/* && \
    apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*

COPY logging.properties ${TOMCAT_HOME}/conf/logging.properties
COPY server.xml ${TOMCAT_HOME}/conf/server.xml
COPY context.xml ${TOMCAT_HOME}/conf/context.xml
COPY entry.sh ${ENTRY_FILE}

RUN chmod +x ${ENTRY_FILE}
RUN ln -s ${CATALINA_HOME} /usr/local/tomcat
VOLUME ["/opt/tomcat/logs"]

WORKDIR ${CATALINA_HOME}

CMD ["/opt/entry.sh"]