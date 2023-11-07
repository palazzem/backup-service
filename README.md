# Photography Backup

Docker container that uses [Borg](https://borgbackup.readthedocs.io/en/stable/) and [rclone](https://rclone.org/) to create backups deployed
in Google Cloud Storage.

## Requirements

* A Google account with a [GCP](https://cloud.google.com/) project (billing must be enabled)
* `gcloud` CLI to configure your GCP authentication
* `terraform` to provision the required resources on GCP
* `docker` to build and run the backup container

## Configure Cloud Storage

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

## Backup Service

### Configure Backup Environment

To boostrap your environment, launch the following commands from the repository folder:
```bash
mkdir -p config/
mkdir -p cache/
cp env.example .env
chmod 600 .env
```

Docker Compose uses automatically the `.env` file. You must update included values as follows:
* `DATA_PATH`: is the folder you want to backup. Example: `/home/user/Pictures`.
* `BORG_PASSPHRASE`: is the key used to encrypt Borg repository. Check Borg documentation for more details.
* `RCLONE_REMOTE_PATH`: is the remote storage path in `rcloud` format. Example: `REMOTE_NAME:BUCKET_NAME`.
* `CROND_SCHEDULE`: is the schedule used by `crond` to execute the backup. Example: `0 2 * * *` (every day at 2 AM).

### Start the Container

Once the configuration is done, you can run the container as a service that will execute the backup based
on the `CROND_SCHEDULE`. If the backup is not initialized, the container will create a new repository in the
`rclone` mount folder.

To run the container as a service, use the following command:
```bash
docker compose up -d
```

### Extract the Archive

To extract the backup archive you must stop any running container. Once the container is stopped, you can
use the following helper:
```bash
docker compose run --rm -ti backup extract.sh
```

## Development

We accept external contributions even though the project is mostly designed for personal needs.
If you think some parts can be exposed with a more generic interface, feel free to open a
[GitHub issue](https://github.com/palazzem/photography-backup/issues) to discuss your suggestion.
