@build:
  docker run --rm \
    --volume="$PWD:/srv/jekyll:Z" \
    -it jekyll/jekyll:latest \
    jekyll build -w
