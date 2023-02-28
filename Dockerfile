# minEE-Builder (fedora minimal builder EE)
ARG EE_BASE_IMAGE=quay.io/fedora/fedora-minimal:37
FROM $EE_BASE_IMAGE

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.source https://github.com/aknochow/minee-builder/Dockerfile

USER root
RUN \
microdnf update -y && \
microdnf -y upgrade && \
microdnf install -y \
dumb-init \
fuse-overlayfs \
git-core \
golang \ 
jq \
make \
nano \
ncurses \
podman \
podman-docker \
python3 \
python3.9 \
python3-bcrypt \
python3-cffi \
python3-markupsafe \
python3-pip \
python3-pynacl \
python3-pyrsistent \
python3-pyyaml \
python3-ruamel-yaml \
python3-setuptools_scm \
python3-wheel \
shadow-utils \
tree \
vim \
&& microdnf clean all

RUN \
pip install \
ansible-lint[lock]==6.12.2 \
ansible-runner==2.3.1 \
paramiko==3.0.0 \
jmespath==1.0.1 \
setuptools_scm
RUN pip install --upgrade pip

# EEUSER root
WORKDIR /tmp
COPY bashrc /home/runner/.bashrc

RUN \
pip3 install --progress-bar=off --compile --only-binary :all: \
ansible-lint[lock]==6.12.2 \
ansible-runner==2.3.1 \
paramiko==3.0.0 \
jmespath==1.0.1 \
setuptools_scm
RUN pip3 install --upgrade pip

RUN mkdir -p ~/.ansible/roles /usr/share/ansible/roles /etc/ansible/roles && \
rm -rf $(pip3 cache dir) && \
# Avoid "fatal: detected dubious ownership in repository at" with newer git versions
# See https://github.com/actions/runner-images/issues/6775
git config --system --add safe.directory / && \
  # Create bashrc file with colored prompt using container name
printf "export CONTAINER_NAME=$CONTAINER_NAME\n" >> /home/runner/.bashrc

RUN useradd runner; \
echo -e "runner:1:999\nrunner:1001:64535" > /etc/subuid; \
echo -e "runner:1:999\nrunner:1001:64535" > /etc/subgid;

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

# In OpenShift, container will run as a random uid number and gid 0. Make sure things
# are writeable by the root group.
RUN for dir in \
      /home/runner \
      /home/runner/.ansible \
      /home/runner/.ansible/tmp \
      /home/runner/local \
      /home/runner/.config \
      /runner \
      /home/runner \
      /runner/env \
      /runner/inventory \
      /runner/project \
      /runner/artifacts ; \
    do mkdir -m 0775 -p $dir ; chmod -R g+rwx $dir ; chown -R runner $dir ; chgrp -R root $dir ; done
RUN for file in \
      /home/runner/.ansible/galaxy_token \
      /etc/passwd \
      /etc/group ; \
    do touch $file ; chmod g+rw $file ; chgrp root $file ; done

# Collections
ADD collections /home/runner/.ansible/collections
RUN ansible-galaxy collection install /home/runner/.ansible/collections/*    

ARG _REPO_URL="https://raw.githubusercontent.com/containers/podman/main/contrib/podmanimage/stable"
ADD $_REPO_URL/containers.conf /etc/containers/containers.conf
ADD $_REPO_URL/podman-containers.conf /home/runner/.config/containers/containers.conf

RUN mkdir -p /home/runner/.local/share/containers && \
    chown runner:root -R /home/runner && \
    chmod 644 /etc/containers/containers.conf

# Copy & modify the defaults to provide reference if runtime changes needed.
# Changes here are required for running with fuse-overlay storage inside container.
RUN sed -e 's|^#mount_program|mount_program|g' \
           -e '/additionalimage.*/a "/var/lib/shared",' \
           -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
           /usr/share/containers/storage.conf \
           > /etc/containers/storage.conf

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /home/runner/.local/share/containers

# add some helpful CLI commands to check we do not remove them inadvertently and output some helpful version information at build time.
RUN set -ex \
&& ansible --version \
&& ansible-lint --version \
&& ansible-runner --version \
&& podman --version \
&& python3 --version \
&& git --version \
&& rpm -qa \
&& uname -a

ADD entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["entrypoint"]

# Switch from root
USER runner
