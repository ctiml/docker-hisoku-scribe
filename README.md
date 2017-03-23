# docker-hisoku-scribe
Docker scribe for Hisoku

### files

- build-image.sh: build script
- config/scribed.conf: scribed conf file
- test/test.js: scribe test client

### build docker image

```
./build-image.sh
```

### run container

```
docker run -d --name scribe -p 1463:1463 -v /srv/logs/scribed:/srv/logs/scribed hisoku/scribe /usr/local/bin/scribed /srv/config/scribed.conf
```

### test

```
cd test
npm install scribe
node test.js
```
