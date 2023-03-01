# minEE (fedora minimal Exectuion Environment)
ARG EE_BASE_IMAGE=quay.io/fedora/fedora-minimal:37
FROM $EE_BASE_IMAGE

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.source https://github.com/aknochow/minee/Dockerfile

# dnf basics
USER root
RUN microdnf -y update && microdnf -y upgrade
RUN microdnf -y install dumb-init git-core jq python tree vim
RUN microdnf clean all

# Avoid "fatal: detected dubious ownership in repository at" with newer git versions
# See https://github.com/actions/runner-images/issues/6775
RUN git config --system --add safe.directory /

# Python
RUN python3 -m ensurepip && python3 -m pip install --upgrade pip
RUN python3 -m pip install --progress-bar=off --compile --only-binary :all: \
ansible-lint ansible-runner \
jmespath paramiko pyyaml
RUN rm -rf $(python3 -m pip cache dir)

# Runner
RUN useradd runner
RUN echo -e "runner:1:999\nrunner:1001:64535" >> /etc/subuid
RUN echo -e "runner:1:999\nrunner:1001:64535" >> /etc/subgid
RUN install -d -m 0775 -o runner -g root /home/runner/.ansible/tmp /runner /work
COPY bashrc bashrc
RUN install -m 775 -o runner -g root bashrc /home/runner/.bashrc && rm bashrc
RUN install -m 775 -o runner -g root /dev/null /home/runner/.ansible/galaxy_token
RUN chmod g+rw /etc/{group,passwd}
#RUN mkdir -p ~/.ansible/roles /usr/share/ansible/roles /etc/ansible/roles

# add some helpful CLI commands to check we do not remove them inadvertently and output some helpful version information at build time.
RUN set -ex \
&& ansible --version \
&& ansible-lint --version \
&& ansible-runner --version \
&& python --version \
&& git --version \
&& rpm -qa \
&& uname -a

# Play alias. Saving keystrokes since 2015*
RUN ln -s /usr/local/bin/ansible-playbook /usr/local/bin/play

ADD entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint

# Switch to runner user
USER runner
WORKDIR /work
ENTRYPOINT ["entrypoint"]