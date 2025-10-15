UNAME_M = $(shell uname -m)
ifndef TARGET_PLATFORMS
	ifeq ($(UNAME_M), x86_64)
		TARGET_PLATFORMS:=linux/amd64
	else ifeq ($(UNAME_M), aarch64)
		TARGET_PLATFORMS:=linux/arm64
	else 
		TARGET_PLATFORMS:=linux/$(UNAME_M)
	endif
endif

TAG ?= ${TAG}
# sanitize the tag
DOCKER_TAG := $(shell echo $(TAG) | sed 's/+/-/g')

export DOCKER_BUILDKIT?=1

REPO ?= rafiusky
IMAGE = $(REPO)/rke2-upgrade:$(DOCKER_TAG)

BUILD_OPTS = \
	--platform=$(TARGET_PLATFORMS) \
	--build-arg TAG=$(TAG) \
	--tag "$(IMAGE)"

.PHONY: push-image
push-image: download-assets
	docker buildx build \
		$(BUILD_OPTS) \
		$(IID_FILE_FLAG) \
		--sbom=true \
		--attest type=provenance,mode=max \
		--push \
		--file ./Dockerfile \
		.

.PHONY: publish-manifest
publish-manifest:
	IMAGE=$(IMAGE) ./scripts/publish-manifest

.PHONY: download-assets
download-assets: 
	./scripts/download
