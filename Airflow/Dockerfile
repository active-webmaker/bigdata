FROM apache/airflow:2.7.0

# 필요한 추가 패키지 설치 (예: 하둡 연결, AWS, 기타 필요한 라이브러리)
RUN pip install --no-cache-dir apache-airflow-providers-apache-hadoop \
    apache-airflow-providers-apache-spark \
    apache-airflow-providers-amazon

# 필요한 환경 변수를 설정 (필요에 따라 수정)
ENV AIRFLOW_HOME=/opt/airflow
ENV AIRFLOW__CORE__EXECUTOR=KubernetesExecutor
ENV AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=False

# Airflow 사용자 및 권한 설정 (필요 시)
RUN useradd -ms /bin/bash airflow

# 작업 디렉토리 설정
WORKDIR /opt/airflow

# entrypoint 설정 (기본 entrypoint를 사용할 수도 있음)
ENTRYPOINT ["entrypoint.sh"]

# Airflow 웹 서버와 스케줄러를 실행
CMD ["webserver", "--port", "8080"]
