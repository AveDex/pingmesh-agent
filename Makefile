# Image registry, name and tag. You can override them with environment variables.
REGISTRY   ?= ave-registry.cn-hongkong.cr.aliyuncs.com/infra
IMAGE_NAME ?= pingmesh-agent
IMAGE_TAG  ?= v1.0.2

# Architectures to build for. Docker buildx is required for multi-arch builds.
ARCHS ?= amd64
# Target OS for the container.
OS = linux
# Default architecture for 'make run'
RUN_ARCH ?= amd64

.PHONY: all build push run clean

all: build

# Build Docker images for all specified architectures.
# Example: make build
build:
	@echo "Building Docker images for OS=$(OS) ARCHS=($(ARCHS))"
	@for arch in $(ARCHS); do \
		echo "---> Building for linux/$${arch}"; \
		docker build \
			--platform linux/$${arch} \
			--build-arg OS=$(OS) \
			--build-arg ARCH=$${arch} \
			-t $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)-$${arch} . ; \
	done

# Push all architecture-specific images to the registry.
# Example: make push REGISTRY=docker.io/my-user
push:
	@echo "Pushing Docker images to $(REGISTRY)"
	@for arch in $(ARCHS); do \
		echo "---> Pushing $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)-$${arch}"; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)-$${arch}; \
	done

# Run the Docker container locally.
# This is useful for testing on a local Docker daemon.
# Example: make run RUN_ARCH=arm64
run:
	@echo "Running the $(IMAGE_NAME) container locally for arch $(RUN_ARCH)..."
	docker run --rm -p 9115:9115 $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)-$(RUN_ARCH)

# Remove locally built Docker images.
# Example: make clean
clean:
	@echo "Cleaning up local Docker images..."
	@for arch in $(ARCHS); do \
		image="$(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)-$${arch}"; \
		if [ -n "$$(docker images -q $${image})" ]; then \
			echo "---> Removing $${image}"; \
			docker rmi $${image}; \
		fi \
	done