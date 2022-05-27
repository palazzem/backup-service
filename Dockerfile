FROM alpine:latest
LABEL maintainer="Emanuele Palazzetti <emanuele.palazzetti@gmail.com>"

# Copy scripts
COPY bin/* /usr/local/bin/

# Add dependencies and make scripts executable
RUN apk add --no-cache borgbackup rclone && \
  chmod a+x /usr/local/bin/initialize_archive && \
  chmod a+x /usr/local/bin/create_snapshot
