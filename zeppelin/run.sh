#!/bin/bash

# Wait for other services
echo "Waiting for namenode..."
until nc -z namenode 9000; do
  sleep 5
done

echo "Waiting for Spark master..."
until nc -z spark-master 7077; do
  sleep 5
done

# Configure Zeppelin environment
cat > $ZEPPELIN_HOME/conf/zeppelin-env.sh << EOF
#!/bin/bash
export JAVA_HOME=${JAVA_HOME}
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}
export SPARK_HOME=/opt/spark
export HADOOP_HOME=${HADOOP_HOME}
export SPARK_SUBMIT_OPTIONS="--packages io.delta:delta-core_2.12:1.2.1"
EOF

# Configure Zeppelin with Hadoop and Spark properties
cat > $ZEPPELIN_HOME/conf/zeppelin-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>zeppelin.server.addr</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>zeppelin.notebook.dir</name>
    <value>/notebook</value>
  </property>
  <property>
    <name>zeppelin.interpreter.connect.timeout</name>
    <value>60000</value>
  </property>
</configuration>
EOF

# Configure Spark defaults for Delta Lake support
mkdir -p $ZEPPELIN_HOME/conf/
cat > $ZEPPELIN_HOME/conf/spark-defaults.conf << EOF
spark.jars.packages io.delta:delta-core_2.12:1.2.1
spark.sql.extensions io.delta.sql.DeltaSparkSessionExtension
spark.sql.catalog.spark_catalog org.apache.spark.sql.delta.catalog.DeltaCatalog
spark.master spark://spark-master:7077
spark.hadoop.fs.defaultFS hdfs://namenode:9000
spark.driver.memory 1g
spark.executor.memory 1g
spark.yarn.am.memory 1g
EOF

# Configure Spark interpreter
cat > $ZEPPELIN_HOME/conf/interpreter.json << EOF
{
  "interpreterSettings": {
    "spark": {
      "id": "spark",
      "name": "spark",
      "group": "spark",
      "properties": {
        "spark.master": "spark://spark-master:7077",
        "spark.submit.deployMode": "client",
        "spark.app.name": "Zeppelin",
        "spark.yarn.queue": "default",
        "spark.executor.memory": "1g",
        "spark.driver.memory": "1g",
        "spark.hadoop.fs.defaultFS": "hdfs://namenode:9000",
        "zeppelin.spark.useHiveContext": "false",
        "zeppelin.pyspark.python": "python3",
        "zeppelin.dep.additionalRemoteRepository": "spark-packages,http://dl.bintray.com/spark-packages/maven,false;"
      },
      "dependencies": [
        {
          "groupArtifactVersion": "io.delta:delta-core_2.12:1.2.1"
        }
      ]
    }
  }
}
EOF

# Start Zeppelin
exec $ZEPPELIN_HOME/bin/zeppelin.sh