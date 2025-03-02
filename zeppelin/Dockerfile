FROM bde2020/hadoop-base:latest


# Update apt-key handling and repositories
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update || true


# Install required packages
RUN apt-get install -y --no-install-recommends wget procps python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

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