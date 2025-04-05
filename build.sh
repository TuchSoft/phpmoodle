#!/bin/bash

# Nome e tag dell'immagine
IMAGE_NAME="phpmoodle"
IMAGE_TAG="latest"

# Puoi passarli come argomenti: ./build.sh nome tag
if [ "$1" ]; then
  IMAGE_NAME="$1"
fi

if [ "$2" ]; then
  IMAGE_TAG="$2"
fi

# Comando di build
docker buildx build \
  --platform linux/amd64 \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  --file Dockerfile \
  --no-cache \
  --progress=plain \
  .

# Suggerimento: per usare cache, rimuovi --no-cache
# Per push: aggiungi --push se stai usando un registry remoto
