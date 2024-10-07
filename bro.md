
# [bro](https://github.com/broisnischal/broisnischal/blob/main/bro)

A multifunctional Bash script for handling project setup, repository creation, npm tasks, Docker cleanup, and more. Designed to streamline your development workflow on macOS and Linux.

### Step 1: Download the Script

```sh
curl -s https://github.com/broisnischal/broisnischal/raw/main/bro -o bro
```

### Step 2: Make the Script Executable

Set the proper permissions to make it executable:

```sh
chmod +x bro
```

### Step 3: Add to path

```sh
sudo mv bro /usr/local/bin/
```

### Usage

```sh
bro help

backend git:(vms_backend_dev) bro help 
Help:
  create   - Create a new project or repository
  setup    - Set up the environment
  update   - Update the project
  cleanup   - Clean up temporary files
  npm      - Run npm commands
  docker    - Run docker commands
  search    - Search on Google or YouTube
  help     - Show this help message
``` 
