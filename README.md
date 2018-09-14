# docker-alpine-snipe-it
Docker container with Alpine+Nginx+PHP-FPM and Snipe-IT assets management tool running inside

## How to build

Before building container, make sure you've correct timezone. By default it uses Europe/Berlin timezone.

```bash
git clone https://github.com/l13t/docker-alpine-snipe-it
cd docker-alpine-snipe-it
GIT_COMMIT=$(git rev-parse HEAD)
docker build -t snipe-it/alpine --build-arg BUILD_DATE=$(date '+%Y-%m-%dT%H:%M:%S%z') --build-arg VERSION=$GIT_COMMIT .
```

## How to run container

You need to edit `env.variables` with your parameters. For this installation you need to have pregenerated `APP_KEY`.

```bash
docker run --env-file ./env.variables -d -p 80:80 --name snipe-it snipe-it/alpine
```

## Important notes

* For version 4.6.4 for some reason `APP_URL` should be specified without http(s) in URL
* Alpine version forced to be 3.8 as latest stable

## TODO for next releases

- [ ] Add generation of `APP_KEY` if it is not defined
- [ ] Kubernetes deployment template
