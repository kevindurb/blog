@build:
  docker run --rm \
    --volume="$PWD:/srv/jekyll:Z" \
    -it jekyll/jekyll:latest \
    jekyll build

@serve:
  docker run --rm \
    --volume="$PWD:/srv/jekyll:Z" \
    -p 4000:4000 \
    -it jekyll/jekyll:latest \
    jekyll serve -D -l
