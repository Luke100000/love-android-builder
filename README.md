# love-android-builder

Docker image for turning a `game.love` archive into signed Android `apk` and
`aab` artifacts using [love-android](https://github.com/love2d/love-android).

The image is meant to be built once per LÖVE/love-android version and reused
from `docker run` in game projects.

Docker Hub image:
[`Luke100000/love-android-builder`](https://hub.docker.com/r/luke100000/love-android-builder)

## Package A Game

From a game project containing `game.love`:

```bash
mkdir -p out keystore-cache

docker run --rm \
  -v "$PWD:$PWD" \
  -e APP_NAME="My Game" \
  -e APPLICATION_ID="com.example.mygame" \
  -e VERSION_CODE=1 \
  -e VERSION_NAME="1.0.0" \
  -e GAME_LOVE="$PWD/game.love" \
  -e OUT_DIR="$PWD/out" \
  -e OUTPUT_NAME=my-game \
  -e KEYSTORE="$PWD/keystore-cache/release.keystore" \
  -e KEYSTORE_ALIAS=release \
  -e KEYSTORE_PASSWORD="change-me" \
  -e ARTIFACTS="apk aab" \
  luke100000/love-android-builder:11.5
```

Outputs are written to `out/my-game.apk` and `out/my-game.aab`.

If `KEYSTORE` does not exist, the entrypoint creates one. Keep that file and
password stable for future releases of the same Android application.

## Runtime Options

Required:

- `GAME_LOVE`
- `KEYSTORE`
- `KEYSTORE_ALIAS`
- `KEYSTORE_PASSWORD`

Common optional variables:

- `OUT_DIR`, default `/out`
- `OUTPUT_NAME`, default `game`
- `APP_NAME`, default `Game`
- `APPLICATION_ID`, default `org.love2d.game`
- `VERSION_CODE`, default `1`
- `VERSION_NAME`, default `1.0.0`
- `ORIENTATION`, default `landscape`
- `ARTIFACTS`, default `apk aab`
- `ICON`, optional path to a png mounted in the container
- `MANIFEST`, optional path to a replacement `AndroidManifest.xml`
- `RECORD_AUDIO`, default `false`; set `true` for the recording flavor
- `KEY_PASSWORD`, default same value as `KEYSTORE_PASSWORD`

## Build Images

The image tags and love-android refs are defined in
`config/love-android-versions.tsv`.

Build every configured tag locally:

```bash
scripts/build-images
```

Build one tag:

```bash
scripts/build-images --tag 11.5
```

Build and push to Docker Hub:

```bash
scripts/build-images --push
```

Edit `config/love-android-versions.tsv` when you want to add or retarget a
version.

## Smoke Test

Build the image first, then run:

```bash
scripts/build-images --tag 11.5
scripts/test-image --tag 11.5
```

This packages `example` into `out/example.love`, runs the Docker image, and
writes Android artifacts under `out`.

## GitHub Actions

`.github/workflows/docker.yml` pushes all configured tags to Docker Hub whenever
`main` is updated.

Configure these secrets before pushing from CI:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
