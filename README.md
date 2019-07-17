# React, Django & Postgres Application

This is a set up so that we can easily create apps that use  React (set up with [`create-react-app`](https://npm.im/create-react-app)) for the front end application, Django with Django Rest Framework (DRF) on the backend (to take advantage of the amazing admin UI) and Postgres as the database. It comes setup with both DRF Authentication as well as DRF-jwt for token based authentication.

## Running

1. `./scripts/docker_start.sh --build`

1. There should now be two servers running:
  - [http://127.0.0.1:8000](http://127.0.0.1:8000) is the Django (API) app
  - [http://127.0.0.1:3000](http://127.0.0.1:3000) is the React (UI) app

## Using `docker-compose run` to issue one-off commands

If you want to run a one-off command, like installing dependencies, you can use the `docker-compose run <service_name> <cmd>`.

For example, to install a Javascript dependency and save that information to `package.json` we could run:
`docker-compose run --rm ui npm install --save axios`
