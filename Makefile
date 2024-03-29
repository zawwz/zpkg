

deploy: build
	scripts/server_deploy.sh

build:
	scripts/shcompile src/main.sh > zpkg && chmod +x zpkg

# minimized build with lxsh
var_exclude = TMPDIR ZPKG_.* _ZPKG_.* SSH_ADDRESS HTTP_ADDRESS PKG_PATH COMPRESSION ALLOW_ROOT UPDATE_REMOVE NOSUDO ROOT_PATH DEBUG
minimal: minimal-deploy

minimal-deploy: minimal-build
	scripts/server_deploy.sh

minimal-build:
	lxsh -o zpkg -M --exclude-var "$(var_exclude)" src/main.sh
