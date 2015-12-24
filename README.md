# leisurelink/ubuntu-node-build-machine

A docker image for building nodejs packages, with dependencies, for deployment on Ubuntu.

## What's in the box

`ubuntu-node-build-machine` is intended as a build machine. Its purpose is to build [nodejs](https://nodejs.org/en/) packages within an environment that matches the environment in which the package will be executed.

We've been running node applications on docker containers in production for over a year now and have encountered a few issues along the way by performing an `npm install` on a build server and then packaging the resulting application into a docker image. Some subtle inconsistencies can occur when our applications reference packages that have build steps that involve native resources. These occur during `npm install` and often detect the available libraries (linux headers, openssl, etc.) and step down in some way when those headers/libraries are not available. Anyone who has watched the mongodb driver fail back to a pure JS bson implementation knows what we're talking about here.

This docker image helps us do it more right.

This build machine image is for targeting `ubuntu:14.04`, we also have `leisurelink/alpine-node-build-machine` for targeting `alpeine:3.2` and `leisurelink/centos-node-build-machine` for targeting `centos:7.1`. They are all very similar.

This image is for building our node based applications. Once built, we package the application into another docker image via a seperate `Dockerfile`. This two step process enables us to build and run leaner docker images for use as the runtime.

## Building Your Package

All you need to use this image is docker and some nodejs source code.

From the directory where your source resides:

```bash
docker run --rm --volume `pwd`:/source/ leisurelink/abuntu-node-machine
```

**WARNING:** By mounting your local directory, the build will take place in the current folder. To ensure a clean build, the build script removes the `node_modules` folder so that all packages get built with the assets present inside the container. For the duration of the build its probably best if you leave the files alone on the host filesystem.

### Private Repositories

If your `package.json` file refers to private git repositories, you will need to provide authority to the builder when it is run. We mount an SSH key for this purpose:

**Mount an SSH identity**

```bash
docker run --rm --volume `pwd`:/source/ --volume /path-to-key/id_rsa:/tmp/id_rsa leisurelink/ubuntu-node-build-machine
```

### Private NPMs

If your `package.json` file refers to private NPM repositories, you will need to provide authority to the builder when it is run:

**Specify an NPM Authentication Token**

```bash
docker run --rm --volume `pwd`:/source/ -env NPM_AUTH_TOKEN=0000000-0000-0000-0000-00000000000 leisurelink/ubuntu-node-build-machine
```

### Keep it Simple

The script that performs the _build_ is `perform-build.sh`. We're open to suggestions and pull request but want to keep it simple; since we're building a node app, we rely on `npm install`.

If your project has _special needs_, follow [Keith Cirkel's Hot to Use npm as a Build Tool](http://blog.keithcirkel.co.uk/how-to-use-npm-as-a-build-tool/). Your goal should be to ensure that everything that needs to heppen in order for your build to succeed occurs as part of `npm install`. Notably, this means adding `preinstall` and/or `postinstall` scripts to your `package.json`.

If your build process has _very special needs_, then you'll need your own, specialized docker image that sets up the enviornement appropriately for those special needs.

## Tags (Asset Versions)

Clone this repository and build the `Dockerfile` to see concrete version information related to the ubuntu packages present on the image; there are many.

* **latest, 1.0.0** (Ubuntu:14.04, nodejs 4.2.4)

## License

[MIT](https://github.com/LeisureLink/ubuntu-node-build-machine/blob/master/LICENSE)
