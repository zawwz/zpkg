

deploy: build
	scripts/server_deploy.sh

build:
	scripts/shcompile src/main.sh > zpkg && chmod +x zpkg

