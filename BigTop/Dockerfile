# 베이스 이미지로 Ubuntu를 사용 (다른 리눅스 배포판도 가능)
FROM ubuntu:22.04

# 환경 변수 설정 (필요한 경우 적절히 수정)
ENV DEBIAN_FRONTEND=noninteractive
ENV BIGTOP_VERSION=3.2.0
# 사용할 BigTop 버전

# 필수 패키지 업데이트 및 설치
RUN apt-get update && apt-get install -y \
    curl \
    git \
    openjdk-8-jdk \
    python3 \
    sudo \
    && apt-get clean

# BigTop 빌드 도구 설치
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y build-essential maven gradle

# BigTop 소스 다운로드 (필요한 버전의 BigTop을 클론)
RUN git clone https://github.com/apache/bigtop.git /bigtop && \
    cd /bigtop && \
    git checkout release-${BIGTOP_VERSION}

# BigTop 빌드 및 설정
WORKDIR /bigtop
RUN ./gradlew bigtop-packages

# Hadoop, Spark 등의 빅데이터 패키지를 설치하고 환경을 설정
RUN ./gradlew hadoop-deb
RUN ./gradlew spark-deb
RUN ./gradlew kafka-deb
RUN ./gradlew hive-deb
RUN ./gradlew flink-deb

# 컨테이너 시작 시 실행할 기본 명령어 (예: Hadoop 실행)
CMD ["/usr/local/hadoop/sbin/start-dfs.sh"]
