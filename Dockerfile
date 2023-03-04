# minEE-Builder (minimal Execution Environment Builder)
# Base minEE - https://github.com/aknochow/minee/Dockerfile
ARG EE_BASE_IMAGE=quay.io/aknochow/minee
FROM $EE_BASE_IMAGE
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.source https://github.com/aknochow/minee-builder/Dockerfile

USER root

# dnf packages
RUN microdnf -y update  
RUN microdnf -y upgrade
RUN microdnf -y install \
fuse-overlayfs \
golang \
kubernetes-client \
make \
nano \
podman \
podman-docker \
python3.9
RUN microdnf clean all

# Python (system default)
RUN python3 -m ensurepip
RUN pip3 install --upgrade pip
RUN python3 -m pip install --progress-bar=off --compile --only-binary :all: \
kubernetes \
oauthlib \
requests \
setuptools_scm

# Python 3.9 (required by awx setuptools scm check)
RUN python3.9 -m ensurepip
RUN python3.9 -m pip install --upgrade pip
RUN python3.9 -m pip install setuptools_scm

# Podman
RUN install -d -m 0775 -o runner -g root \
/home/runner/.config/containers \
/home/runner/.local/share/containers \
/var/lib/shared/overlay-images \
/var/lib/shared/overlay-layers \
/var/lib/shared/vfs-images \
/var/lib/shared/vfs-layers 
RUN touch /var/lib/shared/{overlay-images/images.lock,overlay-layers/layers.lock,vfs-images/images.lock,vfs-layers/layers.lock}
ARG _REPO_URL="https://raw.githubusercontent.com/containers/podman/main/contrib/podmanimage/stable"
ADD $_REPO_URL/containers.conf /etc/containers/containers.conf
ADD $_REPO_URL/podman-containers.conf /home/runner/.config/containers/containers.conf
# Copy & modify the defaults to provide reference if runtime changes needed.
# Changes here are required for running with fuse-overlay storage inside container.
RUN sed \
-e 's|^#mount_program|mount_program|g' \
-e '/additionalimage.*/a "/var/lib/shared",' \
-e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
/usr/share/containers/storage.conf > /etc/containers/storage.conf
# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /home/runner/.local/share/containers
RUN chmod 644 /etc/containers/containers.conf
RUN chown -R runner:root /home/runner

USER runner
WORKDIR /work

# Ansible-Galaxy Collections
RUN ansible-galaxy collection download \ 
ansible.posix \
community.general \
community.kubernetes \
containers.podman
RUN cd collections && ansible-galaxy collection install -r requirements.yml
RUN rm -rf collections

ENTRYPOINT ["entrypoint"]