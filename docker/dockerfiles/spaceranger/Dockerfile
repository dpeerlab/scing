FROM centos:7

LABEL maintainer="Tobias Krause (krauset@mskcc.org)"

ARG VERSION
ARG DOWNLOAD_URL
ENV PATH /opt/spaceranger-${VERSION}:$PATH

RUN yum group install -y "Development Tools" \
    && yum install -y which

# space ranger binaries
RUN curl -o spaceranger-${VERSION}.tar.gz ${DOWNLOAD_URL} \
    && tar xzf spaceranger-${VERSION}.tar.gz \
    && rm -rf spaceranger-${VERSION}.tar.gz \
    && mv spaceranger-${VERSION} /opt/

WORKDIR /opt

ENTRYPOINT [ "spaceranger" ]