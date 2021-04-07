# zpkg

Basic and simple packaging system

Designed to be used by anyone and deployed anywhere,
it is a very basic packaging system with basic functionnality but very portable

Official repo: [https://zpkg.zawz.net](https://zpkg.zawz.net)

## As user

Requirements:
- sudo
- wget
- tar
- xz/gzip

Optional:
- pixz/pigz (faster compression/decompression)

### Installing

```shell
wget -qO- https://zpkg.zawz.net/install.sh | sh
```
> By default the config is installed to /etc/zpkg
> This can be changed with the -c option

If you wish to use another repository, substitute `zpkg.zawz.net` for your desired target

### Uninstalling

```shell
zpkg remove $(zpkg list)
sudo rm -r /etc/zpkg
```

### Using

See `zpkg -h` for details


## Deploy on a server

### Requirements

To deploy on a server you need:
- SSH server
- HTTP server
- dedicated zpkg user

You need to be able to SSH to the zpkg user, SSH keys are recommended

### Process

1. Clone this repository

2. Write the desired config in `.zpkgconfig`, see `.zpkgconfig.example`

3. Run `make`

4. Expose the package directory to the HTTP server

### Package architecture

```
.
+-- DEPS
+-- DESC
+-- ROOT
|    +-- /
+-- HOME
     +-- ~
```
- The ROOT directory represents the root filesystem
- The HOME directory represents the home directory of the user
- The DEPS file contains dependency packages separated by spaces or newlines. Dependencies are package names from the repository
- The DESC file contains the description of the package

### Deploying packages

`zpkg deploy <dir...>`
> Target directories are structured as described above <br>
> The name of the directory is the package name

### Updating

`git pull && make`

## Functionality

- Install/Remove/Update packages
- Dependency resolution
- Config redirection
- User Home package files

### Absent (and unplanned) functionality

- Versions
- Multi-repo
- Hooks
