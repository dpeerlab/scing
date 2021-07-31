# SCING: Single-Cell pIpeliNe Garden

Pronounced as "sing" /siŋ/

<pre>
 ______     ______     __     __   __     ______
/\  ___\   /\  ___\   /\ \   /\ "-.\ \   /\  ___\
\ \___  \  \ \ \____  \ \ \  \ \ \-.  \  \ \ \__ \
 \/\_____\  \ \_____\  \ \_\  \ \_\\"\_\  \ \_____\
  \/_____/   \/_____/   \/_/   \/_/ \/_/   \/_____/

</pre>

Containerized/WDLized pipelines built by Single Cell Research Initiative.

Pipeline   | Description
---------- | --------------------------------------------------------------
SEQC       | Single-Cell & Single-Nucleus RNA-seq 3' Preprocessor
SEQC-ABA   | SEQC Automated Basic Analysis
Sharp (♯)  | Demultiplexing Hashtag, CITE-seq, Cell Plex, and ASAP-seq
Velopipe   | RNA Velocity using SEQC

## Set Up Build Environment

The best way to build is set up an AWS EC2 instance and build the components from there. Building from your local machine is definitely possible, but you will probably hear heavy CPU fan noise (and possibly some smoke).

Prerequisites:

- bash, curl, tar
- Conda
- Docker

```bash
conda create -n scri-pipelines python=3.8 pip
conda activate scri-pipelines
pip install -r requirements.txt
```

## Configure

Set `registry` in `config.yaml` to your container registry.

The following will use, for example, `hisplan` in Docker Hub as your container registry.

```yaml
versoin: 1.0
containers:
  registry: hisplan
```

where you need to replace `hisplan` with your own Docker Hub.

If you want to use Red Hat Quay.io:

```yaml
versoin: 1.0
containers:
  registry: quay.io/dpeerlab
```

where you need to replace `dpeerlab` with your own Quay.io namespace.

If you want to use Amazon ECR (EC2 Container Registry):

```yaml
versoin: 1.0
containers:
  registry: 583643567512.dkr.ecr.us-east-1.amazonaws.com
```

Note that Amazon ECR must be set up in advance.

## Log In to Your Container Registry

### Docker Hub

```bash
docker login
```

### Red Hat Quay.io

```bash
docker login quay.io
```

In addition to the login, you must set an OAuth access token so that the build script can create public repositories in Red Hat Quay.io:

```bash
export QUAY_AUTH_TOKEN="xyz-123-abc"
```

If you don't have one, you can create one by following [this instruction](https://access.redhat.com/documentation/en-us/red_hat_quay/3/html/red_hat_quay_api_guide/using_the_red_hat_quay_api#create_oauth_access_token).

### Amazon ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 583643567512.dkr.ecr.us-east-1.amazonaws.com
```

where `583643567512.dkr.ecr.us-east-1.amazonaws.com` is your registry address.

## Build

In case some of the GitHub repositories are in private, you must set up GitHub auth token to access. If everything is publicly available, you can skip this part.

```bash
export GIT_AUTH_TOKEN="abc-123-xyz"
```

Run the build script:

```bash
python build.py --config=build.yaml
```

## How to Use Pipelines

Prerequisites:

- Cromwell
- AWS Genomics Workflow

## To Do

- Support Google Containery Registry.
- Implement parallel build to speed things up.
