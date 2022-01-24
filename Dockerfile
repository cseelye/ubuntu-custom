FROM ubuntu:20.04

ARG ROOT_PASSWORD
ENV ROOT_PASSWORD=${ROOT_PASSWORD:-live}

ARG SOURCE_ISO_URL
ENV SOURCE_ISO_URL=${SOURCE_ISO_URL:-https://releases.ubuntu.com/20.04/ubuntu-20.04.3-desktop-amd64.iso}

ARG ISO_NAME
ENV ISO_NAME=${ISO_NAME:-custom-ubuntu.iso}

ARG OUTPUT_DIR
ENV OUPUT_DIR=${OUTPUT_DIR:-/output}

ARG BUILD_DIR
ENV BUILD_DIR=${BUILD_DIR:-/root/builder}

ARG SOURCE_DIR
ENV SOURCE_DIR=${SOURCE_DIR:-/root/src}

RUN printf 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";\n' >> /etc/apt/apt.conf.d/01norecommends
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install --yes \
        binutils \
        ca-certificates \
        curl \
        dbus \
        debootstrap \
        grub-efi-amd64-bin \
        grub-pc-bin \
        mtools \
        rsync \
        squashfs-tools \
        vim \
        xorriso \
    && apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR $SOURCE_DIR
CMD ["./build-custom-iso"]
