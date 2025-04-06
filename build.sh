#!/bin/bash

# Tag dell'immagine
IMAGE_TAG="latest"

# Puoi passarli come argomenti: ./build.sh nome tag
if [ "$1" ]; then
  IMAGE_TAG="latest,$1"
fi

# Comando di build
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag "tuchsoft/phpmoodle:${IMAGE_TAG}" \
  --file Dockerfile \
  --progress=plain \
  --push \
  .

# Suggerimento: per usare cache, rimuovi --no-cache
# Per push: aggiungi --push se stai usando un registry remoto
