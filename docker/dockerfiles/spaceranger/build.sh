cd /data/sail/isabl/tools/scing/docker/dockerfiles/spaceranger

VERSION=2.1.0
IMAGE_NAME=cromwell-spaceranger
REGISTRY=docker.io/sailmskcc
DOWNLOAD_URL="https://cf.10xgenomics.com/releases/spatial-exp/spaceranger-2.1.0.tar.gz?Expires=1693391773&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=AxV1PGnLwJtUCu6vJhH9b7FP8ePuuzpF2uXZgu5BF1GFucMEs-gdv9EmftwTQ95Tw1AwKoo-6ueyufs1d6SXgWGCXpXLwr4ejrL8FvtDK1ImzqVitm~RVhZCfA1tgmfzqVBZYi6~PUlp2JerAqgnHeA67oIyx~cwRsbR7B07056oEzhGTyDUXvQhZUV-aFABxSOnDLpJV-dIuIpn5gO6px0oG1IBJiJ46XH8VeJz7YbQEzQIDo8vnk563pCexX6t5Rj~vx22fDMuRaLE5Vgl8pFeqKqOr-FAhJvdzpOn8eGuiuAde24KAgJcHNBNGtVD2sAKYtyWUjdsCPJ8Q-7CKA__"

docker build \
    --tag ${IMAGE_NAME}:${VERSION} \
    --build-arg DOWNLOAD_URL=${DOWNLOAD_URL} \
    --build-arg VERSION=${VERSION} .

git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch cromwell.jar' HEAD
