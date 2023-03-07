# minEE-builder

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
### x86_64
```
REPOSITORY                                TAG               IMAGE ID       CREATED             SIZE
quay.io/aknochow/minee-builder            latest            312822a6841b   About an hour ago   1.22 GB
quay.io/aknochow/minee-builder            cs9               312822a6841b   About an hour ago   1.22 GB
quay.io/aknochow/minee-builder            ubi9              0fbec3537645   About an hour ago   1.15 GB
quay.io/aknochow/minee-builder            f37               5d5d081da712   About an hour ago   1.7 GB
```
_Built with:_
```
buildah version 1.27.3 (image-spec 1.0.2-dev, runtime-spec 1.0.2-dev)
Red Hat Enterprise Linux release 9.1 (Plow)
5.14.0-162.12.1.el9_1.x86_64
```

### aarch64

https://github.com/aknochow/minee-builder/tree/aarch64
