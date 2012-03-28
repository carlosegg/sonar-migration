#!/bin/bash
TARGET_DIR=/tmp/sonarMigration
if  ! [ -d "/home/develenv" ]; then
   echo "[ERROR] Develenv no está instalado"
   exit 1
fi
if [ -d "/home/develenv/bin" ]; then
    PROJECT_HOME_DEVELENV=/home/develenv
else
    pushd .
    cd /home/develenv/develenv-*
    PROJECT_HOME_DEVELENV=$PWD
    popd 	
fi
sonar_jdbc_password=develenv
projectName=develenv
sonar_user=carlosg


rm -Rf $TARGET_DIR
mkdir -p $TARGET_DIR/bin

cp -R ../* $TARGET_DIR
curl http://develenv.googlecode.com/svn/trunk/develenv/sonar/src/main/scripts/installSonarDB.sh >>$TARGET_DIR/bin/installSonarDB.sh
sed -i s:"SONAR_HOME=":"SONAR_HOME=$PROJECT_HOME_DEVELENV/app/sonar":g $TARGET_DIR/platform/tomcat/webapps/sonar/WEB-INF/classes/sonar-war.properties
sed -i s:"\${sonar\.jdbc\.password}":"${sonar_jdbc_password}":g $TARGET_DIR/bin/installSonarDB.sh
sed -i s:"\${projectName}":"${projectName}":g $TARGET_DIR/bin/installSonarDB.sh
sed -i s:"\${sonar\.user}":"${sonar_user}":g $TARGET_DIR/bin/installSonarDB.sh
sed -i s:"\. \./setEnv\.sh":"\. $PROJECT_HOME_DEVELENV/bin/setEnv\.sh":g $TARGET_DIR/bin/installSonarDB.sh
chmod u+x $TARGET_DIR/bin/installSonarDB.sh
echo $PROJECT_HOME_DEVELENV
exit 0


exit 0
/etc/init.d/develenv stop
rm -Rf $PROJECT_HOME_DEVELENV/platform/tomcat/webapps/sonar
rm -Rf $PROJECT_HOME_DEVELENV/platform/tomcat/conf/Catalina/*
rm -Rf $PROJECT_HOME_DEVELENV/platform/tomcat/work/*
rm -Rf $PROJECT_HOME_DEVELENV/platform/tomcat/temp/*
rm -Rf $PROJECT_HOME_DEVELENV/platform/tomcat/logs/*
rm -Rf $PROJECT_HOME_DEVELENV/app/sonar







 

