FROM python:3.12-slim

COPY ./conf/docker/* /tmp/
RUN /tmp/setup.sh

WORKDIR /code

ENTRYPOINT ["/code/entrypoint.sh"]

COPY --chown=trisiki:trisiki ./conf/pip /code/conf/pip

ENV VIRTUAL_ENV=/var/run/trisiki/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN mkdir -p $VIRTUAL_ENV && \
    python3 -m venv $VIRTUAL_ENV && \
    pip install -q --upgrade pip && \
    pip install -q -r /code/conf/pip/requirements.txt

COPY --chown=trisiki:trisiki ./ /code

################################################################################
## create application version and revision files
################################################################################

ARG VERSION=0.0.0
ARG GIT_REVISION

RUN mkdir -p /var/tmp && \
    echo $VERSION > /var/tmp/VERSION && \
    echo $GIT_REVISION > /var/tmp/REVISION
