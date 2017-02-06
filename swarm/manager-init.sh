#!/bin/bash

{{ source "common.ikt" }}

set -o errexit
set -o nounset
set -o xtrace

{{/* Install Docker */}}
{{ include "install-docker.sh" }}

{{/* Set up infrakit */}}
{{ include "infrakit.sh" }}

mkdir -p /etc/docker
cat << EOF > /etc/docker/daemon.json
{
  "labels": {{ INFRAKIT_LABELS | to_json }}
}
EOF

{{/* Reload the engine labels */}}
kill -s HUP $(cat /var/run/docker.pid)
sleep 5

# Set up Docker Remote API port -- this works for upstart based systems, not systemd (before Ubuntu 15.04)
echo DOCKER_OPTS="\"-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock\"" >> /etc/default/docker
service docker restart  # starts :4243

{{ if eq INSTANCE_LOGICAL_ID SPEC.SwarmJoinIP }}

  {{/* The first node of the special allocations will initialize the swarm. */}}
  docker swarm init --advertise-addr {{ INSTANCE_LOGICAL_ID }}  # starts :2377

{{ else }}

  {{/* The rest of the nodes will join as followers in the manager group. */}}
  docker swarm join --token {{ SWARM_JOIN_TOKENS.Manager }} {{ SPEC.SwarmJoinIP }}:2377

{{ end }}
