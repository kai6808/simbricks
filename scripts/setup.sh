#! /bin/bash

# This is the script to setup the environment for the CloudLab experiments.

# exit if any command fails
set -e

# function to setup SSH
setup_ssh() {
    echo "Setting up SSH..."
    mkdir -p ~/.ssh
    echo "Please paste your SSH public key (ssh-rsa ...): "
    read SSH_KEY
    echo "$SSH_KEY" >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    echo "SSH setup completed"
}

# parse the command line arguments
SETUP_SSH=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--setup-ssh) SETUP_SSH=true ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# setup SSH if requested
if $SETUP_SSH; then
    setup_ssh
fi

# install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world
echo "Docker installed successfully"

# solve the docker permission issue and pull the pre-built Docker image
sudo usermod -aG docker $USER
sg docker -c "docker pull simbricks/simbricks"
exec sudo -u $USER /bin/bash