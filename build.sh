#!/bin/bash
# Puoi passarli come argomenti: ./build.sh nome tag
if [ -z "$1" ]; then
  echo "Provide tag"
  exit 1
fi

IMAGE_TAG=$1

# Comando di build
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag "tuchsoft/phpmoodle:${IMAGE_TAG}" \
  --tag "tuchsoft/phpmoodle:latest" \
  --file Dockerfile \
  --progress=plain \
  --push \
  .

