FROM node

RUN apt-get update -qq && \
    apt-get -qq \
        --yes \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        install git mercurial

WORKDIR /app/
COPY ./package.json /app/package.json

RUN npm install -q

RUN apt-get autoremove && apt-get clean

ENTRYPOINT ["./conf/entrypoint.sh"]
