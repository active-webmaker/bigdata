# Python 베이스 이미지 사용
FROM python:3.9-slim-buster

# 작업 디렉토리 설정
WORKDIR /app

# 로컬에서 개발 완료된 소스 파일 및 requirements 파일 복사
COPY Flask/. .

# 의존성 패키지 설치
RUN pip install --no-cache-dir -r requirements.txt

# Flask WAS 실행 명령 (예시)
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:80"]