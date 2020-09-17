FROM openjdk:8-jdk-buster
LABEL maintainer="JS Minet"

ENV HADOOP_VERSION 3.1.4
ENV HADOOP_HOME /opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR ${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}
ENV HADOOP_LOG_DIR ${HADOOP_LOG_DIR:-$HADOOP_HOME/logs}

ENV DFS_NAMENODE_RPC_BIND_HOST ${DFS_NAMENODE_RPC_BIND_HOST:-0.0.0.0}
ENV DFS_NAMENODE_RPC_PORT ${DFS_NAMENODE_RPC_PORT:-8020}
ENV DFS_NAMENODE_HTTP_PORT ${DFS_NAMENODE_HTTP_PORT:-9870}
ENV DFS_NAMENODE_HTTP_ADDRESS ${DFS_NAMENODE_RPC_BIND_HOST}:${DFS_NAMENODE_HTTP_PORT}
ENV FS_DEFAULTFS hdfs://${DFS_NAMENODE_RPC_BIND_HOST}:${DFS_NAMENODE_RPC_PORT}
ENV DFS_NAMENODE_NAME_DIR ${DFS_NAMENODE_NAME_DIR:-/opt/name}
ENV DFS_DATANODE_DATA_DIR ${DFS_DATANODE_DATA_DIR:-/opt/data}
ENV DFS_REPLICATION ${DFS_REPLICATION:-3}

ENV BUILD_DEPS tini
ENV PATH $PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt

RUN set -ex && \
    apt-get update && DEBIAN_FRONTEND=noninteractive && \
	apt-get install -y --no-install-recommends ${BUILD_DEPS} && \
	wget --progress=bar:force:noscroll -O hadoop-binary.tar.gz \
	"http://apache.mirror.iphh.net/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" && \
	tar -xvf hadoop-binary.tar.gz && \
	rm hadoop-binary.tar.gz && \
	cd ${HADOOP_HOME} && \
	chmod +x /usr/local/bin/docker-entrypoint.sh && \
	mkdir -p ${DFS_NAMENODE_NAME_DIR} \
	         ${DFS_DATANODE_DATA_DIR} && \
	rm -rf /var/lib/apt/lists/*

COPY etc/hadoop/* ${HADOOP_HOME}/etc/hadoop/

ENTRYPOINT ["docker-entrypoint.sh"]

VOLUME ["$DFS_NAMENODE_NAME_DIR", "$DFS_DATANODE_DATA_DIR", "$HADOOP_CONF_DIR"]

CMD ["namenode"]