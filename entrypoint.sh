#!/bin/bash

function setDefault {
  if [[ $RUNAS_USER_NAME == "" ]]; then
    RUNAS_USER_NAME=jira
  fi
  if [[ $DATA_DIR == "" ]]; then
    DATA_DIR=/data/
  fi
  if [[ $SHARE_DIR == "" ]]; then
    SHARE_DIR="/sharedata"
  fi
  if [[ $SET_JVM_MAXIMUM_MEMORY == "" ]]; then
    SET_JVM_MAXIMUM_MEMORY=1024m
  fi
  if [[ $SET_JVM_MINIMUM_MEMORY == "" ]]; then
    SET_JVM_MINIMUM_MEMORY=1024m
  fi
}

function createUSER {
  if [[ $(cat /etc/shadow | grep "${RUNAS_USER_NAME}") != "" ]]; then
    return
  fi
  useradd ${RUNAS_USER_NAME}
  echo 'JIRA_USER="'${RUNAS_USER_NAME}'"' > /jiraBinFiles/bin/user.sh
  echo 'export JIRA_USER' >> /jiraBinFiles/bin/user.sh
}

function chmodDIR {

  chown -R ${RUNAS_USER_NAME} /jiraBinFiles/
  chmod -R 755 /jiraBinFiles/
  if [ ! -d "${DATA_DIR}" ]; then
    mkdir -p ${DATA_DIR}
  fi
  if [ ! -d "$SHARE_DIR" ]; then
    mkdir -p ${SHARE_DIR}
  fi
  if [[ $(ls -ald ${DATA_DIR} | awk '{print $3}') != "${RUNAS_USER_NAME}" ]]; then
    chown -R ${RUNAS_USER_NAME} ${DATA_DIR}
    chown -R ${RUNAS_USER_NAME} ${SHARE_DIR}
  fi
  if [[ $(ls -ald ${DATA_DIR} | awk '{print $1}') != "drwxr-xr-x" ]]; then
    chmod -R 755 ${DATA_DIR}
    chmod -R 755 ${SHARE_DIR}
  fi
}


function showHelp {
  echo 'RUN: You can add args with your run container command such as :
    docker run [-e options] <imageName> [tomcat options] [other options]
    -e options:
      SET_JVM_MINIMUM_MEMORY="1024m" # set JVM -Xms
      SET_JVM_MAXIMUM_MEMORY="1024M" # set JVM -Xms 
      DATA_DIR="/data"       # set your data path
      SHARE_DIR="/sharedata" # cluster use those

    tomcat options:
      https://www.oracle.com/java/technologies/javase/vmoptions-jsp.html
      https://www.cwiki.us/display/CONFLUENCEWIKI/Recognized+System+Properties

    more:
      You can only set mysql connect num when your service is normal. After you set you need restart your service
      file youDataPath/confluence.cfg.xml
      this is  mysql connect num

      <property name="hibernate.c3p0.max_size">1000</property>

      this file have a lot of options

    '
  exit
}


function fixXsrfError {
  echo 'fix The security token is missing error'
  OLD_VALUE='jira.xsrf.enabled.desc[^\n]+\n\s+[^\n]+value>'
  NEW_VALUE='jira.xsrf.enabled.desc</descriptionKey><default-value>false</default-value>'
  sed -r -i ':a;N;s@'${OLD_VALUE}'@'${NEW_VALUE}'@g;ta' /jiraBinFiles/atlassian-jira/WEB-INF/classes/jpm.xml  | grep "jira.xsrf.enabled.desc"
}



function prepareRUN {
  fixXsrfError
  setDefault
  echo 'welcome access my github https://github.com/mengxifl/'
  echo "set data dir to "${DATA_DIR}
  echo "jira.home = "${DATA_DIR} > /jiraBinFiles/atlassian-jira/WEB-INF/classes/jira-application.properties
  echo "set tomcat parms"

  echo 'JVM_MINIMUM_MEMORY="'$SET_JVM_MINIMUM_MEMORY'"' >> /var/setenv.sh
  echo 'JVM_MAXIMUM_MEMORY="'$SET_JVM_MAXIMUM_MEMORY'"' >> /var/setenv.sh

  cat /jiraBinFiles/bin/setenv.sh.raw | grep -v  -E  "JVM_MINIMUM_MEMORY=|JVM_MAXIMUM_MEMORY=" >> /var/setenv.sh




  GET_ALL_ARGS=`echo $ARGS '${JAVA_OPTS}'`

  echo ${GET_ALL_ARGS}

  sed -i "s@export JAVA_OPTS@JAVA_OPTS=\"${GET_ALL_ARGS}\";export JAVA_OPTS@g" /var/setenv.sh
  /bin/cp /var/setenv.sh /jiraBinFiles/bin/setenv.sh
  mv /var/setenv.sh /var/setenv.sh.bak
  createUSER
  chmodDIR

}


function setRunArgs() {
  ARGS=""
  while [[ $# -gt 0 ]]; do
    ARGS=`echo $ARGS $1`
    shift
  done
}


function main {
  while [[ $# -gt 0 ]]; do
    if [[ $1 == "--help" || $1 == "-h" ]]; then
      showHelp
    fi
    if [[ $1 == "--crackHelp" || $1 == "-c" ]]; then
      crackHelp
    fi
    shift
  done
}




main $@
setRunArgs $@
prepareRUN
runuser -m ${RUNAS_USER_NAME} -c "/jiraBinFiles/bin/start-jira.sh -fg"
