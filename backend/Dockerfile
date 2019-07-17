FROM python:3.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app
RUN pip install -q --upgrade pip && \
    pip install -q -r requirements.txt

COPY ./ /app
RUN useradd -ms /bin/false trisiki
RUN chown -R trisiki: /app

ENTRYPOINT ["/app/entrypoint.sh"]
