# zpkg

Simple and basic packaging system

Designed to be used by anyone and deployed anywhere,
it is a very basic packaging system without much functionnality but very portable

Official repo: `http://zawz.net/zpkg`

## As user

### Installing

```shell
curl -SO http://zawz.net/zpkg/install.sh
sh install.sh
```

If you wish to use another repository, substitute `zawz.net/zpkg` for your desired target  

### Using

See `zpkg help`

## Deploy on a server

### Requirements

To deploy on a server you need:
- SSH server
- HTTP server
- dedicated zpkg user

You need to be able to SSH to the zpkg user. SSH keys are recommended

### Process

1. Write the desired config in `.config`, see `.config.example`

2. Run `server_deploy.sh`

3. Make available the package directory to the HTTP server

## Functionality

- Install packages
- Remove packages
- Update packages
- Config redirection

### Non-present functionality

- Dependencies
- Versions
- Multi-repo

These functionalities are not planned to be added,
zpkg is designed to be a basic package manager
