# Trove

## About

Collections in Trove are available for use by Tufts University faculty and students, for teaching and research purposes. Collections will include images selected by faculty for teaching Art History courses. Faculty and students can create personal collections of images selected from those available in Trove.


## Running Test Locally

* MIRA test docker environment should be running already


```
docker-compose up test
docker exec -it trove_test_1 /bin/bash
xvfb-run -a bundle exec rake spec SPEC_OPTS="--tag ~noci_local"

```

There are two testing tags, noci and noci_local some tests aren't working in the dockerized environment we'll re-address when we move to Ruby 3
