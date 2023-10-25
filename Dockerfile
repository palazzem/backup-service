#checkov:skip=CKV_DOCKER_2: No healthchecks are needed
#checkov:skip=CKV_DOCKER_3: No users are needed
FROM alpine:3.18
LABEL maintainer="Emanuele Palazzetti <emanuele.palazzetti@gmail.com>"

# Copy scripts
COPY scripts/* /usr/local/bin/

# Add backup dependencies
RUN mkdir /config \
  && apk add --no-cache borgbackup rclone fuse3
