#!/usr/bin/env bash
echo "********************`date`********************"
if [ ! ${SERVER_PORT} ]; then
  SERVER_PORT=8080;
  echo "SERVER_PORT=${SERVER_PORT}"
fi

SERVER_PORT_SERVER=$[SERVER_PORT+3111];
echo "SERVER_PORT_SERVER=${SERVER_PORT_SERVER}"

SERVER_PORT_REDIRECT=$[SERVER_PORT+3222];
echo "SERVER_PORT_REDIRECT=${SERVER_PORT_REDIRECT}"

SERVER_PORT_AJP=$[SERVER_PORT+3333];
echo "SERVER_PORT_AJP=${SERVER_PORT_AJP}"

if [ ! ${SERVER_NAME} ]; then
  SERVER_NAME=$(hostname);
fi

if [ ! ${JAVA_XMX} ]; then
  JAVA_XMX=200M;
fi

#echo tomcat/conf/server.xml
SERVER_XML=${CATALINA_HOME}/conf/server.xml
echo "<?xml version='1.0' encoding='utf-8'?>
<Server port=\"-1\" shutdown=\"SHUTDOWN\">
    <Listener className=\"org.apache.catalina.startup.VersionLoggerListener\" />
    <Listener className=\"org.apache.catalina.core.AprLifecycleListener\" SSLEngine=\"on\" />
    <Listener className=\"org.apache.catalina.core.JreMemoryLeakPreventionListener\" />
    <Listener className=\"org.apache.catalina.mbeans.GlobalResourcesLifecycleListener\" />
    <Listener className=\"org.apache.catalina.core.ThreadLocalLeakPreventionListener\" />
    <Service name=\"Catalina\">
        <Executor name=\"tomcatThreadPool\" namePrefix=\"catalina-exec-\" maxThreads=\"512\" minSpareThreads=\"4\"/>
        <Connector executor=\"tomcatThreadPool\"
    		   port=\"${SERVER_PORT}\"
		       protocol=\"HTTP/1.1\"
		       URIEncoding=\"UTF-8\"
		       maxHttpHeaderSize=\"524288\"
               connectionTimeout=\"20000\"
               redirectPort=\"${SERVER_PORT_REDIRECT}\" >
            <UpgradeProtocol className=\"org.apache.coyote.http2.Http2Protocol\" />
        </Connector>
    <Engine name=\"Catalina\" defaultHost=\"localhost\">
      <Host name=\"localhost\" appBase=\"webapps\" unpackWARs=\"true\" autoDeploy=\"true\">
      <Valve className=\"org.apache.catalina.valves.AccessLogValve\"
            directory=\"logs/access\"
            prefix=\"\" suffix=\"_access_log\"
            pattern=\"%{yyyy-MM-dd HH:mm:ss}t ${SERVER_NAME} %p %h %D %m %U %q %s 0 0 &quot;%{User-Agent}i&quot; &quot;%{Referer}i&quot;\"
            fileDateFormat=\"yyyy-MM-dd_HH\"/>
      </Host>
    </Engine>
    </Service>
</Server>" > ${SERVER_XML}

echo "cleaning and reset network start..........."

rm -rf ${CATALINA_HOME}/webapps/docs
rm -rf ${CATALINA_HOME}/webapps/examples
rm -rf ${CATALINA_HOME}/webapps/manager
rm -rf ${CATALINA_HOME}/webapps/host-manager

echo "REMOVE ALL FILES IN ${CATALINA_HOME}/webapps/"

if [ ! ${SERVER_IP} ]; then
    echo "NOT SET SERVER IP"
else
    echo "set hosts <<<<<<<<<<<"
    cp /etc/hosts /etc/hosts.temp
    sed -i "s/.*$(hostname)/${SERVER_IP} $(hostname)/" /etc/hosts.temp
    cat /etc/hosts.temp > /etc/hosts
    echo "set hosts >>>>>>>>>>>"
fi
echo "cleaning and reset network finish..........."

echo "JAVA_OPTS = ${JAVA_OPTS}"

export CATALINA_OPTS="
-server
-Xms${JAVA_XMX}
-Xmx${JAVA_XMX}
-Xss512k
-XX:NewSize=200M
-XX:MaxNewSize=200M
-XX:+AggressiveOpts
-XX:+UseBiasedLocking
-XX:+DisableExplicitGC
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:+CMSParallelRemarkEnabled
-XX:LargePageSizeInBytes=128m
-XX:+UseFastAccessorMethods
-XX:+UseCMSInitiatingOccupancyOnly
-Duser.timezone=Asia/Shanghai
-Djava.awt.headless=true"

echo "starting tomcat...."
${CATALINA_HOME}/bin/catalina.sh run
