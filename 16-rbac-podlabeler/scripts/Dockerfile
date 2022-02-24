FROM python:2.7-stretch

RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends \
  vim -y  \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN pip install requests==2.19.1

RUN pip install kubernetes==7.0.0

ENV PYTHON_EGG_CACHE=/tmp

WORKDIR /app

USER nobody

COPY label_pods.py label_pods.py

ENTRYPOINT ["python","-u","label_pods.py"]