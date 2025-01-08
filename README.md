[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/big-data-europe/Lobby)

# Hadoop Docker

## Last Changes

- Added the step by step video Tutorial: [Installing a Hadoop Cluster By Docker](https://youtu.be/FvVaQrQC6_w)
- Added a tutorial from scratch to make a Docker based Hadoop cluster. The instructions are from [How to set up a Hadoop cluster in Docker](https://clubhouse.io/developer-how-to/how-to-set-up-a-hadoop-cluster-in-docker/) with some changes and more clarity (I found the blog a little confusing).

## Quick Start

### Install Docker Toolbox on Windows

Install the docker toolbox (as you need docker-machine that is not included in the newer version of the Docker Desktop).
Follow the installation instructions (and use default installation parameters as suggested): [Install Docker Toolbox on Windows](https://docs.docker.com/toolbox/toolbox_install_windows/)

### Run Docker Toolbox

Click the Docker QuickStart icon to launch a pre-configured Docker Toolbox terminal.

### Verify Docker Toolbox Installation
In the command line that just opened (Docker QuickStart) type the following: (this step is optional)

```
  $ docker --version
  $ docker-compose --version
  $ docker-machine –version
```

### Downloading required files

Download this repository as a zip (by clicking on the green button on the top right) and unzip that in the proper location. (like: C:\Users\*---*\Desktop)

### Deploy a Hadoop cluster

In the terminal (Docker QuickStart) navigate to the unzipped folder that you made in the last step by using the "cd" command:
```
  cd ~/Desktop/docker-hadoop-master
```

Run this:
```
  $ docker-compose up -d
```
This command makes multiple containers of Hadoop (1 namenode, 3 Datanodes and etc. as specified in "docker-compose.yml") at the same time.

### Checking the Hadoop cluster status

After pulling the Hadoop docker images from the web for the first time and building them, you can see the running containers by:
```
  $ docker ps
```

Also, you can go to http://DockerIP:9870/ from your browser to see the namenode status. (Docker IP from by running:"docker-machine config default")

### Test the Hadoop cluster

Let's go to the namenode container. Type the following in the terminal (Docker QuickStart):
```
  $ docker exec -it namenode bash
```
now we are in the name node. So from now on till I mention we are typing our commands in the namenode (not in the Docker QuickStart terminal, it is the same terminal but you are now in the namenode terminal. (you can exit from the name node by typing "exit")).

In the namenode, we will make a directory and 2 files in it (f1.txt and f2.txt). We fill them up with some simple content. type this:

```
  # mkdir input
  # echo "Hello World" >input/f1.txt
  # echo "Hello Docker" >input/f2.txt
```

now we will make a directory in HDFS with the same name and copy all the content in the "input" directory we just made to it. So they are now in the HDFS and distributed over our 3 datanodes:
```
  # hadoop fs -mkdir -p input
  # hdfs dfs -put ./input/* input
```

now type
```
  # exit
```
to return to Docker QuickStart terminal. (make sure you are in the previous directory (C:\Users\*---*\Desktop\docker-hadoop-master).

Now let's run a wordcount example over our 2 files in the HDFS and read the output. First, let's put the wordcount file into the HDFS and find the namenode Container ID.
```
  $ docker container ls
```
Find the name node in the "IMAGE" column (sth. like bde2020/hadoop-namenode:...) and copy the container ID of your namenode.

Now run the following to copy the jar file to the namenode docker container:
```
  $ docker cp ./hadoop-mapreduce-examples-2.7.1-sources.jar THE_ID_YOU_JUST_COPIED:hadoop-mapreduce-examples-2.7.1-sources.jar
```

So let go back to the namenode Terminal:
```
  $ docker exec -it namenode bash
```

now lets run the wordcount file that we just copied to the namenode over 2 files in the HDFS cluster. (Reading from the "input" directory and saving the results in the "output" directory.)
```
  # hadoop jar hadoop-mapreduce-examples-2.7.1-sources.jar org.apache.hadoop.examples.WordCount input output
  # hdfs dfs -cat output/part-r-00000
```
Congrats! we did it. Hope you enjoyed this tutorial.

To shut down the cluster and remove containers, use this command:
```
  $ docker-compose down
```

The END!

# Original Big Data Europe repository tutorial...

## Supported Hadoop Versions
See repository branches for supported Hadoop versions

## Supported Hadoop Versions
Getting Started:
To deploy an example HDFS cluster, run:
```
  docker-compose up
```

Run example wordcount job:
```
  make wordcount
```

Or deploy in a swarm:
```
docker stack deploy -c docker-compose-v3.yml hadoop
```

`docker-compose` creates a docker network that can be found by running `docker network list`, e.g. `dockerhadoop_default`.

Run `docker network inspect` on the network (e.g. `dockerhadoop_default`) to find the IP the Hadoop interfaces are published on. Access these interfaces with the following URLs:

* Namenode: http://<dockerhadoop_IP_address>:9870/dfshealth.html#tab-overview
* History server: http://<dockerhadoop_IP_address>:8188/applicationhistory
* Datanode: http://<dockerhadoop_IP_address>:9864/
* Nodemanager: http://<dockerhadoop_IP_address>:8042/node
* Resource manager: http://<dockerhadoop_IP_address>:8088/

## Configure Environment Variables

The configuration parameters can be specified in the hadoop.env file or as environmental variables for specific services (e.g. namenode, datanode, etc.):
```
  CORE_CONF_fs_defaultFS=hdfs://namenode:8020
```

CORE_CONF corresponds to core-site.xml. fs_defaultFS=hdfs://namenode:8020 will be transformed into:
```
  <property><name>fs.defaultFS</name><value>hdfs://namenode:8020</value></property>
```
To define dash inside a configuration parameter, use triple underscore, such as YARN_CONF_yarn_log___aggregation___enable=true (yarn-site.xml):
```
  <property><name>yarn.log-aggregation-enable</name><value>true</value></property>
```

The available configurations are:
* /etc/hadoop/core-site.xml CORE_CONF
* /etc/hadoop/hdfs-site.xml HDFS_CONF
* /etc/hadoop/yarn-site.xml YARN_CONF
* /etc/hadoop/httpfs-site.xml HTTPFS_CONF
* /etc/hadoop/kms-site.xml KMS_CONF
* /etc/hadoop/mapred-site.xml  MAPRED_CONF

If you need to extend some other configuration file, refer to base/entrypoint.sh bash script.
