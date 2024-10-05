#!/bin/bash

# Set username for Docker Hub
DOCKER_USERNAME="neeswebservice"  # Change this to your Docker Hub username
GITHUB_USERNAME="broisnischal"  # Change this to your GitHub username

# Check if username is set
if [ -z "$DOCKER_USERNAME" ]; then
  echo "Docker Hub username is not set. Please set it in the script."
  exit 1
fi

# Function to show usage instructions
show_usage() {
  echo "Usage: bro {create|setup|update|cleanup|npm|docker|search|help} <args>"
}

# Function to show help information
show_help() {
  echo "Help:"
  echo "  create   - Create a new project or repository"
  echo "  setup    - Set up the environment"
  echo "  update   - Update the project"
  echo "  cleanup   - Clean up temporary files"
  echo "  npm      - Run npm commands"
  echo "  docker    - Run docker commands"
  echo "  search    - Search on Google or YouTube"
  echo "  help     - Show this help message"
}

# Function to search on Google or YouTube
search() {
  if [ "$1" == "google" ]; then
    query="$2"
    open "https://www.google.com/search?q=${query// /+}"
  elif [ "$1" == "youtube" ]; then
    open "https://www.youtube.com/results?search_query=${2// /+}"
  else
    echo "Usage: bro search {google|youtube} <query>"
  fi
}

check_gh_auth() {
  if ! gh auth status >/dev/null 2>&1; then
    echo "You are not authenticated with GitHub CLI. Please log in."
    gh auth login
  fi
}

# Function to check if a git repository exists
check_git_repo() {
  if [ ! -d .git ]; then
    echo "Initializing a new Git repository..."
    git init
    git add .
    git commit -m "init - first"
  fi
}

# Function to create a GitHub repository
create_repo() {
  repo_name="$1"
  visibility="$2"
  push_flag="$3"

  # Create the GitHub repo
  gh repo create "$repo_name" --"$visibility" --confirm
  
  # Get the URL of the created repo
  repo_url=$(gh repo view "$repo_name" --json url -q ".url")
  echo "Repository created: $repo_url"
  
  # Check if origin already exists
  if git remote get-url origin &>/dev/null; then
    echo "Remote 'origin' already exists. Updating URL..."
    git remote set-url origin "$repo_url"
  else
    echo "Adding remote 'origin'."
    git remote add origin "$repo_url"
  fi
  
  # Set the default branch to main
  git branch -M main

  # If the push flag is set, add, commit, and push
  if [ "$push_flag" == "push" ]; then
    git add .
    git commit -m "chore: init-project 🚀"
    git push --set-upstream origin main
  fi
}

# Function to set up SSH keys
setup_ssh() {
  if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "SSH key already exists. Skipping generation."
  else
    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$1" -f "$HOME/.ssh/id_rsa" -N ""
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_rsa"
    echo "SSH key generated and added to the SSH agent."
  fi

  pbcopy < "$HOME/.ssh/id_rsa.pub"
  echo "SSH key copied to clipboard. Add it to your GitHub account."
}

# Function to update the system
update_system() {
  echo "Updating Homebrew..."
  brew update
  echo "Upgrading installed packages..."
  brew upgrade
  echo "Cleaning up..."
  brew cleanup
  echo "System update completed."
}

# Function to create a new project with boilerplate
create_project() {
  project_name="$1"
  
  mkdir -p "$project_name/src" "$project_name/tests"
  touch "$project_name/README.md"
  echo "# $project_name" > "$project_name/README.md"
  
  echo "Project $project_name created with boilerplate structure."
}

# Function to clean up old files
cleanup_old_files() {
  find "$1" -type f -mtime +30 -exec rm {} \;
  echo "Cleaned up files older than 30 days in $1."
}

# Function to remove all node_modules folders from the system
remove_all_node_modules() {
  echo "Removing all node_modules folders in the system..."
  find / -name "node_modules" -type d -prune -exec rm -rf '{}' +
  echo "All node_modules folders removed."
}

# Function to install global npm packages and update
npm_global_install_update() {
  packages="$@"
  echo "Installing/updating global npm packages: $packages"
  npm install -g $packages
}

# Function to dump all Docker resources
docker_dump() {
  force_flag="$1"
  if [ "$force_flag" == "force" ]; then
    echo "Removing all Docker containers, images, volumes, and networks (including running ones)..."
    docker rm -vf $(docker ps -aq)
    docker rmi -f $(docker images -q)
    docker volume rm $(docker volume ls -q)
    docker network rm $(docker network ls -q)
  else
    echo "Removing all Docker containers, images, volumes, and networks..."
    docker rm $(docker ps -aq)
    docker rmi $(docker images -q)
    docker volume rm $(docker volume ls -q)
    docker network rm $(docker network ls -q)
  fi
}

# Main script execution
case $1 in
  create)
    case $2 in
      repo) 
        create_repo "$3" "$4" "$5"
        ;;
      project) 
        create_project "$3"
        ;;
      *)  
        echo "Usage: bro create {repo|project} <name> [visibility] [push]"
        ;;
    esac
    ;;
  setup)
    case $2 in
      ssh) 
        setup_ssh "$3" 
        ;;
      *) 
        echo "Usage: bro setup {ssh} <args>"
        ;;
    esac
    ;;
  update)
    case $2 in
      system) 
        update_system 
        ;;
      *) 
        echo "Usage: bro update {system}"
        ;;
    esac
    ;;
  cleanup)
    case $2 in
      old_files) 
        cleanup_old_files "$3" 
        ;;
      *) 
        echo "Usage: bro cleanup {old_files} <directory_path>"
        ;;
    esac
    ;;
  npm)
    case $2 in
      remove_node_modules) 
        remove_all_node_modules 
        ;;
      install_update) 
        npm_global_install_update "${@:3}"
        ;;
      *) 
        echo "Usage: bro npm {remove_node_modules|install_update <packages>}"
        ;;
    esac
    ;;
  docker)
    case $2 in
      dump)
        docker_dump "$3"
        ;;
      *) 
        echo "Usage: bro docker {dump} [force]"
        ;;
    esac
    ;;
  search)
    search "$2" "$3"
    ;;
  help)
    show_help
    ;;
  *)
    show_usage
    ;;
esac
