# minEE-builder (aarch64)

A builder image based on minEE (https://github.com/aknochow/minEE)

This image can be used as an Execution Environment in AWX or as a local dev environment for building and testing images.

## Flavors:
#### cs9 - CentOS Stream 9 (default/latest) 
`ansible python version: 3.9.16 (/usr/bin/python3)`
#### ubi9 - Red Hat 9.1 
`ansible python version: 3.9.14 (/usr/bin/python3)`
#### f37 - Fedora 37
`ansible python version: 3.11.2 (/usr/bin/python3)`

## Image details
### aarch64
```
REPOSITORY                                TAG               IMAGE ID       CREATED       SIZE
quay.io/aknochow/minee-builder            ubi9-arm          d8bbf696b4a9   2 hours ago   1.16 GB
quay.io/aknochow/minee-builder            f37-arm           42fdad78a549   2 hours ago   1.71 GB
quay.io/aknochow/minee-builder            cs9-arm           15c0c612f45a   2 hours ago   1.23 GB
quay.io/aknochow/minee-builder            arm               15c0c612f45a   2 hours ago   1.23 GB
```
_Built with:_
```
buildah version 1.29.1 (image-spec 1.0.2-dev, runtime-spec 1.0.2-dev)
Fedora CoreOS 37.20230205.3.0
6.1.9-200.fc37.aarch64
```
