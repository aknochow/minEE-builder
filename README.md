# minEE-builder

A builder image based on minEE (https://github.com/aknochow/minEE)

This image can be used as an Execution Environment in AWX or as a local dev environment for building and testing images.

## Flavors:
#### cs9 - CentOS Stream 9 (default/latest)
#### ubi9 - Red Hat 9.1
#### f37 - Fedora 37

## Image details
### x86_64
```
REPOSITORY                       TAG      IMAGE ID       CREATED             SIZE
quay.io/aknochow/minee-builder   f37      b6f4a883d6d1   11 minutes ago      1.73 GB
quay.io/aknochow/minee-builder   ubi9     9540827b968a   13 minutes ago      1.17 GB
quay.io/aknochow/minee-builder   cs9      a47a9668da87   15 minutes ago      1.24 GB
quay.io/aknochow/minee-builder   latest   a47a9668da87   15 minutes ago      1.24 GB
```
_Built with:_
```
buildah version 1.27.3 (image-spec 1.0.2-dev, runtime-spec 1.0.2-dev)
Red Hat Enterprise Linux release 9.1 (Plow)
5.14.0-162.12.1.el9_1.x86_64
```

### aarch64

https://github.com/aknochow/minee-builder/tree/aarch64
