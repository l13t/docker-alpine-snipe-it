# docker-alpine-snipe-it
Docker container with Alpine+Nginx+PHP-FPM and Snipe-IT assets management tool running inside

## How to build

Before building container, make sure you've correct timezone. By default it uses Europe/Berlin timezone.

```bash
git clone https://github.com/l13t/docker-alpine-snipe-it
cd docker-alpine-snipe-it
GIT_COMMIT=$(git rev-parse HEAD)
docker build -t snipe-it/alpine .
```

By default you'll get container with latest version of Snipe-it. If for any reason you need older version, you need to run `docker build` with additional argument (in example we've version 4.6.0):

```bash
docker build -t snipe-it/alpine --build-arg SNIPEIT_RELEASE=4.6.0 .
```

This version of Alpine won't work with Snipe-it version <= 4.0 because of PHP dependencies.

## How to run container

You need to edit `env.variables` with your parameters. For this installation you need to have pregenerated `APP_KEY`.

```bash
docker run --env-file ./env.variables -d -p 80:80 --name snipe-it snipe-it/alpine
```

## Important notes

* Alpine version forced to be 3.8 as latest stable
* Migration from Snipe-IT version 3 to version 4 should be done manually. There is no automation for this
* APP_URL should be http://127.0.0.1 (nginx is running on port 80)

## TODO for next releases

- [ ] Add generation of `APP_KEY` if it is not defined
- [ ] Kubernetes deployment template
