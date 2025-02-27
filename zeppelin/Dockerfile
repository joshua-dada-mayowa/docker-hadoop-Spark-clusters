FROM bde2020/hadoop-base:2.0.0-hadoop3.2.1-java8

# Install required packages
RUN apt-get update && apt-get install -y wget procps python3 python3-pip

# Set Zeppelin version
ENV ZEPPELIN_VERSION=0.10.1

# Download and extract Zeppelin
RUN wget https://archive.apache.org/dist/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz && \
    tar -xzf zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz && \
    mv zeppelin-${ZEPPELIN_VERSION}-bin-all /opt/zeppelin && \
    rm zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz

# Create log directory
RUN mkdir -p /opt/zeppelin/logs

# Set environment variables
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV PATH=$PATH:${ZEPPELIN_HOME}/bin

# Create directory for notebook
RUN mkdir -p /notebook
VOLUME /notebook

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Ports
EXPOSE 8080

CMD ["/run.sh"]