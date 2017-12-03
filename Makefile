GO?=go
GOPATH=$(shell pwd)
GOOS?=$(shell uname -s|tr A-Z a-z)
GOARCH?=amd64
BINARY_NAME?=service-entrypoint
BUILD_ARGS?=
BUILD_PATH?=go.telemotor.org/service/cmd/service
GO_IMAGE=golang:latest
SOURCE_DIR=./src/go.telemotor.org/service
GOPACKAGES=$(shell find $(SOURCE_DIR) -name '*.go' -not -path "$(SOURCE_DIR)/vendor/*" -exec dirname {} \; | uniq)
GOFILES_NOVENDOR=$(shell find $(SOURCE_DIR) -type f -name '*.go' -not -path "$(SOURCE_DIR)/vendor/*")

DEV_CONFIG_PATH?=$(GOPATH)/config/dev.json
LOCAL_CONFIG_PATH?=$(GOPATH)/config/local.json
TEST_CONFIG_PATH?=/go/config/test.json

build: fmt
	docker run --rm -v $(GOPATH):/go -e GOOS=$(GOOS) -e GOARCH=$(GOARCH) $(GO_IMAGE) $(GO) build $(BUILD_ARGS) -o /go/bin/$(BINARY_NAME) $(BUILD_PATH)

fmt:
	docker run --rm -v $(GOPATH):/go $(GO_IMAGE) $(GO) fmt ${GOPACKAGES}

clean:
	docker run --rm -v $(GOPATH):/go $(GO_IMAGE) $(GO) clean
	rm -rf $(GOPATH)/bin/$(BINARY_NAME)

run: build
	CONFIG_PATH=$(DEV_CONFIG_PATH) $(GOPATH)/bin/$(BINARY_NAME)

local: build
	CONFIG_PATH=$(LOCAL_CONFIG_PATH) $(GOPATH)/bin/$(BINARY_NAME)

test: clean
	docker run --rm -v $(GOPATH):/go -e CONFIG_PATH=$(TEST_CONFIG_PATH) --entrypoint $(GO) $(GO_IMAGE) test -v $(GOPACKAGES)

coverage: clean
	docker run --rm -v $(GOPATH):/go -e CONFIG_PATH=$(TEST_CONFIG_PATH) --entrypoint $(GO) $(GO_IMAGE) test -v -cover $(GOPACKAGES)

check: vet

vet:
	docker run --rm -v $(GOPATH):/go $(GO_IMAGE) $(GO) vet $(GOPACKAGES)

lint:
	ls $(GOFILES_NOVENDOR) | xargs -L1 golint
