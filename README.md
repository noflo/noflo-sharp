# noflo-sharp [![Build Status](https://secure.travis-ci.org/noflo/noflo-sharp.png?branch=master)](http://travis-ci.org/noflo/noflo-sharp)

Fast image resizing components for [NoFlo](http://noflojs.org), powered by [vips](www.vips.ecs.soton.ac.uk).

# Dependencies

Check [sharp](http://github.com/lovell/sharp) for updated instructions of how to install required [dependencies](https://github.com/lovell/sharp#prerequisites).

# Heroku

When creating a new Heroku app:

```bash
heroku apps:create -b https://github.com/ddollar/heroku-buildpack-multi.git

cat << EOF > .buildpacks
https://github.com/automata/heroku-buildpack-vips.git
https://github.com/heroku/heroku-buildpack-nodejs.git
EOF

git push heroku master
```

When modifying an existing Heroku app:

```bash
heroku config:set BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git

cat << EOF > .buildpacks
https://github.com/automata/heroku-buildpack-cairo.git
https://github.com/heroku/heroku-buildpack-nodejs.git
EOF

git push heroku master
```
