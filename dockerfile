From rockylinux:8.9.20231119-minimal

COPY entrypoint.sh /entrypoint.sh
COPY jiraBinFiles /jiraBinFiles
COPY thirdPackage/* /jiraBinFiles/atlassian-jira/WEB-INF/lib/


RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    microdnf install java-17-openjdk ncurses shadow-utils util-linux -y --setopt=keepcache=0 && \
    microdnf clean all && \
    chmod 777 /entrypoint.sh && \
    mv /jiraBinFiles/bin/setenv.sh  /jiraBinFiles/bin/setenv.sh.raw


ENV \
  SET_JVM_MAXIMUM_MEMORY="1024m" \
  SET_JVM_MINIMUM_MEMORY="1024m" \
  DATA_DIR="/data/" \
  SHARE_DIR="/sharedata"

ENTRYPOINT ["/entrypoint.sh"]


