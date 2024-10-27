# docker-jira

A docker image that can let you run jira. But there is no database but had sql lib

mysql-connector-j-8.1.0.jar and mysql-connector-java-5.1.45-bin.jar. If you want to use other db you can use ` -v  <plugin dir>/pluginfile:/jiraBinFiles/atlassian-jira/WEB-INF/lib/pluginfile`

And You need run a db server by your self.

## How to use

1. download those repositories to /docker
2. download confluence file from https://www.atlassian.com/software/jira/download-archives. and unzip all the subdir files to jiraBinFiles
3. run `cd /docker/ && docker build -t jira:v9 .` to build a image

```
docker run -d \
 --restart=always \
-p 0.0.0.0:8080:8080  \
-v ${YOUR_SAVE_DATA}:/data \
-e DATA_DIR=/data \
-e SET_JVM_MAXIMUM_MEMORY="1024m" \
-e SET_JVM_MINIMUM_MEMORY="1024m"  \
jira:v9 [other tomcat parms]
```

enjoy

## Cluster

1. stop service

2. copy 

   1. ${YOUR_SAVE_DATA}/data to a share store
   2. ${YOUR_SAVE_DATA}/pluginsto a share store
   3. ${YOUR_SAVE_DATA}/logos a share store
   4. ${YOUR_SAVE_DATA}/import a share store
   5. ${YOUR_SAVE_DATA}/caches a share store
   6. ${YOUR_SAVE_DATA}/keys a share store

3. edit file ${YOUR_SAVE_DATA}/cluster.properties ehcache will autodiscover other peer

   ```
   jira.node.id = <nodeID>
   jira.shared.home = <share store>
   ehcache.listener.hostName = IP
   ehcache.listener.port = 40001
   ehcache.object.port = 40011
   ```

4. start  service

   ```
   docker run -d \
    --restart=always \
   -p 0.0.0.0:8080:8080  \
   -v ${YOUR_SAVE_DATA}:/data \
   -e DATA_DIR=/data \
   -e SHARE_DIR=<your share data> \
   -e SET_JVM_MAXIMUM_MEMORY="1024m" \
   -e SET_JVM_MINIMUM_MEMORY="1024m"  \
   jira:v9 [other tomcat parms]
   ```

5. copy  all  ${DATA_DIR} data to other peer node.

6. repeat  step 3-4 set and do not set  jira.node.id to same value 

