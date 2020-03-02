# zpkg

Basic and simple packaging system

Designed to be used by anyone and deployed anywhere,
it is a very basic packaging system without much functionnality but very portable

Official repo: [http://zawz.net/zpkg](http://zawz.net/zpkg)

## As user

Requirements:
- sudo
- wget
- tar

Optional:
- pv

### Installing

```shell
wget http://zawz.net/zpkg/install.sh
sh install.sh
```
> By default the config is installed to /etc/zpkg

If you wish to use another repository, substitute `zawz.net/zpkg` for your desired target  


#### Installing to a custom location

Add the -c option to the install script to specify a custom config path for the install

### Uninstalling

```shell
zpkg remove $(zpkg list)
rm -rd /etc/zpkg
```

### Using

See `zpkg -h`


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

### Package architecture

```
.
+-- DEPS
+-- ROOT
|    +-- /
+-- HOME
     +-- ~
```
- The ROOT directory repsesents the root filesystem  
- The HOME directory represents the home directory of the user  
- The DEPS file contains dependency packages separated by spaces or newlines. Dependencies are package names from the repository

### Deploying packages

`zpkg deploy <dir...>`  
> Target directories are structured as described above  
> The package name is the name of the directory

## Functionality

- Install/Remove/Update packages
- Dependency resolution
- Config redirection
- User Home capability

### Non-present functionality

- Versions
- Multi-repo

