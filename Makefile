.EXPORT_ALL_VARIABLES:
APP_VERSION     	= 7.4
INSTANTCLIENT_VER = 12.2.0.1.0
APP_NAME        	= php7-with-oci8
DOCKER_ID_USER  	= dmi7ry
PHP_VERSION				= $(shell echo $(APP_VERSION) | sed -E 's/\.//')
BUILD_DIR					= ./build

.ONESHELL:
.PHONY: build all

all: build

prepare:
	set -e ;\
	rm -rf $(BUILD_DIR)/* ;\
	mkdir -p $(BUILD_DIR) ;\
	cp ./php$(PHP_VERSION)/* $(BUILD_DIR) ;\
	cp ./instantclient/$(INSTANTCLIENT_VER)/* $(BUILD_DIR)

clean-build-dir:
	rm -rf $(BUILD_DIR)/*

build: prepare build-cache
build-clean: prepare build-no-cache

build-cache:
	docker build -t $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION) --build-arg INSTANTCLIENT_VER=$(INSTANTCLIENT_VER) $(BUILD_DIR)

build-no-cache:
	docker build --squash --no-cache -t $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION) --build-arg INSTANTCLIENT_VER=$(INSTANTCLIENT_VER) $(BUILD_DIR)

run:
	docker run -d -p 8000:80 --rm --name $(APP_NAME) $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION)
bash:
	docker exec -it $(APP_NAME) bash
rm:
	docker rm -f $(APP_NAME)

publish: build push

push:
	docker push $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION)
