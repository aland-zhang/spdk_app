FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
# Install dependencies
RUN apt-get update && \
    apt-get install -y curl tzdata kmod && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean


ARG PROXY
ARG NO_PROXY

ENV http_proxy=$PROXY
ENV https_proxy=$PROXY
ENV no_proxy=$NO_PROXY

RUN apt-get update && apt-get install -y \
    libhugetlbfs-bin \
    build-essential \
    git \
    make \
    gcc \
    libc6-dev \
    libaio-dev \
    libssl-dev \
    libnuma-dev \
    uuid-dev \
    && apt-get clean

# Clone SPDK repository
RUN git clone https://github.com/spdk/spdk.git --recursive /spdk

# Set working directory
WORKDIR /spdk

# Build SPDK
RUN cd dpdk \
    git fetch origin \
    git checkout 175af25

WORKDIR /spdk
RUN "./scripts/pkgdep.sh" --all -d
RUN "/spdk/test/common/config/autotest_setup.sh" --test-conf=fio
RUN "/spdk/configure"
RUN make


# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
