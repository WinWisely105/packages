
GO_OS 		:= $(shell go env GOOS)
GO_ARCH		:= $(shell go env GOARCH)

GIT_VERSION	:= $(shell git describe --tags)

current_dir = $(shell pwd)

SAMPLE_NAME = 
SAMPLE_FSPATH = $(PWD)/$(SAMPLE_NAME)

# Absolute File path to Server
SERVER_FSPATH=$(current_dir)/../server

I18N_TEMPLATE_DIR = $(current_dir)/i18n/
I18N_TEMPLATE_NAME = "intl.arb"
I18N_TEMPLATE_PATH = $(I18N_TEMPLATE_DIR)/$(I18N_TEMPLATE_NAME)
I18N_PREFIX_OUT_FILES = "stock"

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

print: ## print
	@echo
	@echo GO_OS: $(GO_OS)
	@echo GO_ARCH: $(GO_ARCH)
	@echo GIT_VERSION: $(GIT_VERSION)
	@echo LIB_FSPATH: $(LIB_FSPATH)
	@echo

	@echo SAMPLE
	@echo SAMPLE_FSPATH: $(SAMPLE_FSPATH)
	@echo

	@echo I18N
	@echo I18N_TEMPLATE_PATH: $(I18N_TEMPLATE_PATH)
	@echo I18N_PREFIX_OUT_FILES: $(I18N_PREFIX_OUT_FILES)
	@echo

	@echo SERVER:
	@echo SERVER_FSPATH: $(SERVER_FSPATH)
	@echo



os-dep:
	# Assume hover make file has ben run

### FLU

flu-config: ## flu-config
	flutter channel beta
	flutter upgrade --force

flu-web-run: ## flu-web-run
	flutter config --enable-web
	cd $(SAMPLE_FSPATH) && flutter run -d chrome

## i18n can be done in 2 ways 
## 1. System Level .i.e  change locale from your device settings.
## 2. App Level .i.e. change language from application settings.
flu-web-build: ## flu-web-build
	flutter config --enable-web
	cd $(SAMPLE_FSPATH) && flutter build web

	# asti desktop
	rm -rf $(SAMPLE_FSPATH)/desktop/resources/app/*
	cp -r $(SAMPLE_FSPATH)/build/web/* $(SAMPLE_FSPATH)/desktop/resources/app
	cd desktop && astilectron-bundler

asti-install:
	# install go-astilectron-bundler
	sudo rm -rf $(GOPATH)/src/github.com/go-astilectron-bundler
	cd $(GOPATH)/src/github.com/ && git clone https://github.com/asticode/go-astilectron-bundler.git
	cd $(GOPATH)/src/github.com/go-astilectron-bundler/astilectron-bundler && go build -o $(GOBIN)/astilectron-bundler

asti-desk-linux:
	./desktop/output/linux-amd64/ION\ Desktop\ App
	
asti-desk-mac:
	./desktop/output/darwin-amd64/MacOS/ion_desktop
	
asti-desk-win:
	./desktop/output/windows-386/ION\ Desktop\ App

flu-mob-run: ## flu-mob-run
	cd $(SAMPLE_FSPATH) && flutter run -d all

flu-desk-run: ## flu-desk-run
	#cd $(SAMPLE_FSPATH) && hover init
	cd $(SAMPLE_FSPATH) && hover run


### GEN 

flu-gen: ## flu-gen
	cd $(SAMPLE_FSPATH) && flutter packages get
	$(MAKE) gen-icons
	$(MAKE) gen-hive
	$(MAKE) gen-proto
	cd $(SAMPLE_FSPATH) && flutter analyze 

gen-icons:
	# mobile and web
	@echo
	@echo Generating icons for Flutter
	@echo
	cd $(SAMPLE_FSPATH) && flutter pub run flutter_launcher_icons:main

	# desktop
	@echo
	@echo Copying icon-png from flutter assets into go assets, so hover can use it
	@echo
	cp $(SAMPLE_FSPATH)/assets/icon/icon.png $(SAMPLE_FSPATH)/go/assets

gen-hive:
	cd $(SAMPLE_FSPATH) && flutter packages pub run build_runner build --delete-conflicting-outputs

gen-proto:
	pub global activate protoc_plugin
	mkdir -p $(SAMPLE_FSPATH)/lib/api/v1/google/protobuf

ifeq ($(GO_OS), windows)
	@echo Windows detected
	protoc empty.proto timestamp.proto wrappers.proto --proto_path=$(LIB_FSPATH)/server/third_party/google/protobuf/ --plugin=$(HOME_PATH)/AppData/Roaming/Pub/Cache/bin/protoc-gen-dart.bat --dart_out=grpc:"$(PROTO_OUTPUT)/client/lib/chat_view/api/v1/google/protobuf"
	protoc chat.proto --proto_path=$(LIB_FSPATH)/server/api/proto/v1/ --plugin=$(HOME_PATH)/AppData/Roaming/Pub/Cache/bin/protoc-gen-dart.bat --dart_out=grpc:"$(PROTO_OUTPUT)/client/lib/chat_view/api/v1/"
else
	protoc empty.proto timestamp.proto wrappers.proto --proto_path=$(LIB_FSPATH)/server/third_party/google/protobuf --plugin=protoc-gen-dart=$(HOME)/.pub-cache/bin/protoc-gen-dart --dart_out=grpc:$(SAMPLE_FSPATH)/lib/api/v1/google/protobuf
	protoc chat.proto --proto_path=$(LIB_FSPATH)/server/api/proto/v1/ --plugin=protoc-gen-dart=$(HOME)/.pub-cache/bin/protoc-gen-dart --dart_out=grpc:$(SAMPLE_FSPATH)/client/lib/chat_view/api/v1/
endif


## LANG

lang-gen: ## gen-len
	# wrapper script to call others to make it seemless
	$(MAKE) lang-gen-go

lang-gen-go: ## lang-gen-go
	# calls our golang tool to do its thing...
	@echo go-flu-gen

lang-gen-json: ## lang-gen-json
	# generate full json files
	i18n flutter --dir $(I18N_TEMPLATE_DIR) --template $(I18N_TEMPLATE_PATH) --prefix $(I18N_PREFIX_OUT_FILES) --languages en,fr,es -f

lang-gen-arb: ## lang-gen-arb
	# generate arb files from json files
	i18n flutter --dir $(I18N_TEMPLATE_DIR)



### ASTI

# 1. dep
# 2. build
# 3. copy flutter web build in
# 4. run (for the desktop your on)

go-desk-dep: ## go-desk-dep
	# as per the readme: https://github.com/asticode/go-astilectron-bundler#installation  !!
	go get -u github.com/asticode/go-astilectron-bundler/...
	cd $(current_dir)/desktop && go install github.com/asticode/go-astilectron-bundler/astilectron-bundler
	which astilectron-bundler

go-desk-build: ## go-desk-build
	# -d is for darwin
	cd $(current_dir)/desktop && astilectron-bundler


go-desk-run-lin: ## go-desk-run-lin
	# SOMEONE on Linux fix this to be correct pathing style
	./desktop/output/linux-amd64/ION\ Desktop\ App
	
go-desk-run-mac: ## go-desk-run-mac
	open $(current_dir)/desktop/output/darwin-amd64/ION\ Desktop\ App.app 
	
go-desk-run-win: ## go-desk-run-win
	# SOMEONE on Windows fix this to be correct pathing style
	$(current_dir)/desktop/output/windows-386/ION\ Desktop\ App.exe