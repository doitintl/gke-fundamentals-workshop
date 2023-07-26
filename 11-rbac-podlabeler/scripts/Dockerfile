FROM python:3.11-slim

WORKDIR /usr/src/app

RUN pip install --no-cache-dir kubernetes==27.2.0

COPY . .

ENTRYPOINT [ "python", "-u", "./label_pods.py" ]
