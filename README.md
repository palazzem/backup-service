# Photography Backup

Docker container that uses [Borg](https://borgbackup.readthedocs.io/en/stable/) and [rclone](https://rclone.org/) to create backups deployed
in Google Cloud Storage.

## Requirements

* A Google account with a [GCP](https://cloud.google.com/) project (billing must be enabled)
* `gcloud` CLI to configure your GCP authentication
* `terraform` to provision the required resources on GCP
* `docker` to build and run the backup container

## Getting Started

### Configure your Storage

Before using this project, you have to configure your GCP authentication using `gcloud` CLI:

```bash
gcloud auth application-default login
```

Create a `.auto.tfvars` file inside `provision/` directory with the following variables set:
```hcl
google_project_id = "<GCP_PROJECT_ID>"
google_region     = "<GCP_REGION>"
google_zone       = "<GCP_ZONE>"
```

Initialize Terraform locally and start the provisioning:
```bash
cd provision
terraform init
terraform apply
```

Once the provision ends, you can re-initialize Terraform to move the global state in your newly created buckets. To do that,
configure your backend by creating a `.gcs.tfbackend` file inside `provision/` directory with the following variables set:
```hcl
bucket = "<YOUR_BUCKET_NAME>"
prefix = "terraform/state"
```

Then, re-initialize Terraform to move the state on Google Cloud Storage:
```bash
terraform init -backend-config=.gcs.tfbackend
```

### Build Backup Container

Build the backup container with the following command:
```bash
docker build -t local/backup:alpine .
```

### Configure your Backup

Create a `.env` file with the following variables set:
* `BORG_PASSPHRASE`: defines the key used to encrypt Borg repository. Check Borg documentation for more details.
* `RCLONE_BUCKET_NAME`: the name of the bucket created by Terraform in the previous step.
* `RCLOUD_REMOTE_NAME`: when you configure your rclone remote, you must use this name.

An example `.env` file looks like:
```bash
BORG_PASSPHRASE=secret_password
RCLONE_REMOTE_PATH=gcp-storage:73858969-bucket-backup
CROND_SCHEDULE=0 2 * * *
```

In this case, the backup encrypted with `secret_password` will be executed in a Google Cloud Storage in a bucket
named `73858969-bucket-backup` every day at 2 AM.

### Run the container

Once the configuration is done, you can run the container as a service that will execute the backup based
on the `CROND_SCHEDULE`. If the backup is not initialized, the container will create a new repository in the
`rclone` mount folder.

To run the container as a service, use the following command:
```bash
docker run --rm -d \
  --env-file .env \
  --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined \
  --volume $PWD/config:/config \
  --volume $PWD/cache:/cache \
  --volume <PATH>:/data:ro \
  local/backup:alpine
```

`<PATH>` should point to the host folder you want to backup.

### Extract the Archive

To extract the backup archive you must stop any running container. Once the container is stopped, you can
use the following helper:
```bash
docker run --rm -d \
  --env-file .env \
  --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined \
  --volume $PWD/config:/config \
  --volume $PWD/cache:/cache \
  --volume <PATH>:/mnt/extract \
  local/backup:alpine extract.sh
```

`<PATH>` should point to the host folder where you want to extract the data.

## Development

We accept external contributions even though the project is mostly designed for personal needs.
If you think some parts can be exposed with a more generic interface, feel free to open a
[GitHub issue](https://github.com/palazzem/photography-backup/issues) to discuss your suggestion.
