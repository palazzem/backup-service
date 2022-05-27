# Photography Backup

Docker container that uses [Borg](https://borgbackup.readthedocs.io/en/stable/) and [rclone](https://rclone.org/) to make a full catalog backup.
In the current stage, the project is not meant to be a generic container for any kind of backup, even though contributions to make it happen
are welcomed!

## Requirements

* Docker to build a standalone container

## Getting Started

1. Pull the latest `alpine` image and create a `photography-backup` container:
```bash
$ git clone https://github.com/palazzem/photography-backup.git
$ docker pull alpine:latest
$ docker build -t photography-backup .
```

2. Create an `env.list` file with the following variables set:
* `BORG_PASSPHRASE`: defines the key used to encrypt Borg repository. Check Borg documentation for more details.
* `RCLOUD_REMOTE_NAME`: when you configure your rclone remote, you must use this `name`.
* `AWS_ACCESS_KEY_ID`: AWS access key.
* `AWS_SECRET_ACCESS_KEY`: AWS secret key.
* `AWS_BUCKET_NAME`: AWS S3 bucket name where Borg repository is stored.

An example `env.list` file looks like:
```bash
BORG_PASSPHRASE=secret_password
RCLOUD_REMOTE_NAME=aws-glacier
AWS_ACCESS_KEY_ID=AKIAACCESSKEY
AWS_SECRET_ACCESS_KEY=Twwr1R+secret_access_key
AWS_BUCKET_NAME=photography-backup
```

3. Run the archive initialization that configures Borg and rclone:
```bash
$ docker run --rm -ti \
  --env-file env.list \
  --volume <PATH_TO_BACKUP>:/mnt/source \
  --volume <BORG_ARCHIVE_PATH>:/var/backup \
  photography-backup:latest initialize_archive
```

`<PATH_TO_BACKUP>` should point to your catalog local folder, while `<BORG_ARCHIVE_PATH>` to where you
want to store the encrypted Borg archive.

In this step `rclone` starts the interactive configuration page that you should complete to create at least one
remote storage.

4. Once the configuration is done, create and synchronize your first snapshot:
```bash
$ docker run --rm -ti \
  --env-file env.list \
  --volume <PATH_TO_BACKUP>:/mnt/source \
  --volume <BORG_ARCHIVE_PATH>:/var/backup \
  photography-backup:latest create_snapshot
```

## Development

We accept external contributions even though the project is mostly designed for personal needs. If you think some parts can be exposed with a
more generic interface, feel free to open a [GitHub issue](https://github.com/palazzem/photography-backup/issues) to discuss your suggestion.
