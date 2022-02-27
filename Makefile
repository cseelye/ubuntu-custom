# Tabs vs spaces are incredibly important in this file! Both are present for a reason, make sure your editor does not change them!

.DEFAULT_GOAL := iso
SHELL = bash -o pipefail

SOURCE_ISO_URL ?= https://releases.ubuntu.com/20.04/ubuntu-20.04.3-desktop-amd64.iso
ISO_NAME ?= custom-ubuntu.iso
ROOT_PASSWORD ?= live
BUILD_DIR ?= /root/builder
OUTPUT_DIR ?= /output
SOURCE_DIR ?= /root/src

ARTIFACT_DIR = $(CURDIR)/out
BUILD_IMAGE_NAME = ubuntu-customizer:latest
BUILD_IMAGE_MARKER = .$(subst :,-,$(BUILD_IMAGE_NAME))

ISO_DEPS = $(wildcard chroot-hooks/*)
ISO_DEPS += $(wildcard iso-hooks/*)
ISO_DEPS += build-custom-iso

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)
ifeq ($(INTERACTIVE),1)
	TTY = --tty
else
	TTY =
endif

# Idempotent deletion of a container image
# $1 the image name
define delete_image
if docker image inspect $1 &>/dev/null; then \
    docker image rm --force $1; \
fi
endef

# This target builds the container used to build the ISO image
.PHONY: builder-image
builder-image: Dockerfile
	docker image build \
        --build-arg ISO_NAME="$(ISO_NAME)" \
        --build-arg ROOT_PASSWORD="$(ROOT_PASSWORD)" \
        --build-arg BUILD_DIR="$(BUILD_DIR)" \
        --build-arg OUTPUT_DIR="$(OUTPUT_DIR)" \
        --build-arg SOURCE_DIR="$(SOURCE_DIR)" \
        --tag=$(BUILD_IMAGE_NAME) \
        .

$(ARTIFACT_DIR):
	mkdir -p $@

.PHONY: iso
iso: $(ARTIFACT_DIR)/$(ISO_NAME)

$(ARTIFACT_DIR)/$(ISO_NAME): $(ISO_DEPS) | $(ARTIFACT_DIR) builder-image
	$(RM) $@ && \
    time docker container run \
        --rm \
        --privileged \
        --interactive \
        $(TTY) \
        --init \
        --volume "$(CURDIR)":"$(SOURCE_DIR)" \
        --volume "$(ARTIFACT_DIR)":"$(OUTPUT_DIR)" \
        --env ISO_NAME="$(ISO_NAME)" \
        --env ROOT_PASSWORD="$(ROOT_PASSWORD)" \
        --env BUILD_DIR="$(BUILD_DIR)" \
        --env OUTPUT_DIR="$(OUTPUT_DIR)" \
        --env SOURCE_DIR="$(SOURCE_DIR)" \
        --name ubuntu-customizer \
        $(BUILD_IMAGE_NAME)

.PHONY: clean
clean:
	$(RM) -r $(ARTIFACT_DIR)/$(ISO_NAME)

.PHONY: clobber
clobber: clean
	$(call delete_image,$(BUILD_IMAGE_NAME))
	$(RM) -r $(ARTIFACT_DIR)
