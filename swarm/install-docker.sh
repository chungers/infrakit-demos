{{ source "common.ikt" }}

# Tested on Ubuntu/trusty

apt-get update -y
apt-get upgrade -y
apt-get install -y jq

wget -qO- https://get.docker.com/ | sh

sudo usermod -aG docker {{ ref "/compute/instance/user" }}

# Tell Docker to listen on port 4243 for remote API access. This is optional.
echo DOCKER_OPTS=\"-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock\" >> /etc/default/docker

# Restart Docker to let port listening take effect.
service docker restart
