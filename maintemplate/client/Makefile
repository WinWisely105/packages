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

flu-mob-run: ## flu-mob-run
	cd $(SAMPLE_FSPATH) && flutter run -d all

flu-mob-build: ## flu-mob-build
	# ios
	# https://flutter.dev/docs/deployment/ios
	# change to ios 11 in xcode for runner and pods
	cd $(SAMPLE_FSPATH)/ios && pod install
	#cd $(SAMPLE_FSPATH) && flutter build ios

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
# 0. make lang-dep => ensure you have the i18n tool
# 1. make lang-gen-json => generate translated json files
# 2. make lang-gen-arb => convert json files to arb

lang-gen: ## gen-len
	# wrapper script to call others to make it seemless
	$(MAKE) lang-gen-go

lang-gen-go: ## lang-gen-go
	# calls our golang tool to do its thing...
	@echo i18n flutter

lang-dep:
	go get -u github.com/getcouragenow/bootstrap/tool/i18n

lang-gen-json: ## lang-gen-json
	# generate full json files
	i18n flutter --dir $(I18N_TEMPLATE_DIR) --template $(I18N_TEMPLATE_PATH) --prefix $(I18N_PREFIX_OUT_FILES) --languages en,fr,es -f

lang-gen-arb: ## lang-gen-arb
	# generate arb files from json files
	i18n flutter --dir $(I18N_TEMPLATE_DIR)

### ASTI

# 1. dep
# 2. build
# 3. run (for the desktop your on)
# 4. pack (for the desktop your on)

go-desk-dep: ## go-desk-dep
	# as per the readme: https://github.com/asticode/go-astilectron-bundler#installation  !!
	go get -u github.com/asticode/go-astilectron-bundler/...
	go get -u github.com/asticode/go-astilectron-bootstrap
	cd $(current_dir)/desktop && go install github.com/asticode/go-astilectron-bundler/astilectron-bundler
	which astilectron-bundler

go-desk-build: ## go-desk-build
	# build flutter web
	flutter config --enable-web
	cd $(SAMPLE_FSPATH) && flutter build web

	# copy flutter web build to desktop/resources/app
	rm -rf $(SAMPLE_FSPATH)desktop/resources/app
	mkdir -p $(SAMPLE_FSPATH)desktop/resources/app/
	cp -r $(SAMPLE_FSPATH)build/web/* $(SAMPLE_FSPATH)desktop/resources/app

	# -d is for darwin
	cd $(SAMPLE_FSPATH)desktop && astilectron-bundler

go-desk-run-lin: ## go-desk-run-lin
	# SOMEONE on Linux fix this to be correct pathing style
	./desktop/output/linux-amd64/ION\ Desktop\ App

go-desk-pack-lin: ## go-desk-pack-lin
	# debian
	cd $(SAMPLE_FSPATH)packer/ && make go-pack-deb

SIGN_KEY_ID_LINUX="Developer ID Application: Amos Wenger (B2N6FSRTPV)"
go-desk-sign-lin:
	debsigs --sign=origin -k ${SIGN_KEY_ID_LINUX} $(SAMPLE_FSPATH)packer/build/linux-deb/*.deb
	debsigs --verify -c $(SAMPLE_FSPATH)packer/build/linux-deb/*.deb
	
go-desk-run-mac: ## go-desk-run-mac
	open $(current_dir)/desktop/output/darwin-amd64/ION\ Desktop\ App.app 

go-desk-pack-mac:  ## go-desk-pack-mac

	#darwin
	#cd $(SAMPLE_FSPATH) && hover init-packaging darwin-bundle

	# skaffold the file system with the pkg templates.
	#cd $(SAMPLE_FSPATH) && hover init-packaging darwin-pkg

	# inject out .app into it.
	cp -rf $(current_dir)/desktop/output/darwin-amd64/ION\ Desktop\ App.app ./Applications/maintemplate.app

	# 


TARGET_MAC=$(current_dir)/desktop/output/darwin-amd64/ION\ Desktop\ App.app 
SIGNKEY_MAC="Developer ID Application: Amos Wenger (B2N6FSRTPV)"
# From: https://developer.apple.com/account
# NOTE: waiting on Apple to approve me...
go-desk-sign-mac: ## go-desk-sign-mac
	# sign *after* packing
	echo TARGET_MAC : $(TARGET_MAC)
	echo SIGNKEY_MAC : $(SIGNKEY_MAC)
	codesign --deep --force --verbose --sign ${SIGNKEY_MAC} "${TARGET}"
	codesign --verify -vvvv "${TARGET}"
	
go-desk-run-win: ## go-desk-run-win
	# SOMEONE on Windows fix this to be correct pathing style
	$(current_dir)/desktop/output/windows-386/ION\ Desktop\ App.exe

go-desk-clean:
	rm -rf $(SAMPLE_FSPATH)desktop/resources/app
	rm -rf $(SAMPLE_FSPATH)desktop/output
	rm -rf $(SAMPLE_FSPATH)desktop/bind_darwin_amd64.go
	rm -rf $(SAMPLE_FSPATH)desktop/bind_linux_amd64.go
	rm -rf $(SAMPLE_FSPATH)desktop/bind_windows_386.go
	rm -rf $(SAMPLE_FSPATH)desktop/windows.syso