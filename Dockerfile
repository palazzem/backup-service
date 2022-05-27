FROM alpine:latest
LABEL maintainer="Emanuele Palazzetti <emanuele.palazzetti@gmail.com>"

# Copy Scripts
COPY initialize_archive.sh /usr/local/bin/initialize_archive
COPY create_snapshot.sh /usr/local/bin/create_snapshot

# Add dependencies and make scripts executable
RUN apk add --no-cache borgbackup rclone && \
  chmod a+x /usr/local/bin/initialize_archive && \
  chmod a+x /usr/local/bin/create_snapshot
