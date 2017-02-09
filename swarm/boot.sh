#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

{{ source "common.ikt" }}

{{/* Set up volumes */}}
{{ include "setup-volume.sh" }}

{{/* Install Docker */}}
{{ if ref "/cluster/install/docker" }} {{ include "install-docker.sh" }} {{ end }}

{{/* Set up infrakit */}}
{{ include "infrakit.sh" }}


{{ if not ref "/cluster/swarm/init" }}
docker swarm init
{{ end }}

{{ $dockerImage := ref "/infrakit/docker/image" }}
{{ $dockerMounts := ref "/infrakit/docker/options/mount" }}
{{ $dockerEnvs := ref "/infrakit/docker/options/env" }}
{{ $pluginsURL := cat (ref "/cluster/config/urlRoot") "/plugins.json" | nospace }}
{{ $groupsURL := cat (ref "/cluster/config/urlRoot") "/groups.json" | nospace }}

{{ $instanceImage := ref "/infrakit/instance/docker/image" }}
{{ $instanceCmd := ref "/infrakit/instance/docker/cmd" }}

echo "Starting up infrakit"

docker run -d --name infrakit {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} \
       infrakit plugin start --wait --config-url {{$pluginsURL}} --exec os --log 5 \
       manager \
       group-stateless \
       flavor-swarm

echo "Starting up instance-aws plugin"
docker run -d --name instance-plugin {{$dockerMounts}} {{$dockerEnvs}} {{$instanceImage}} {{$instanceCmd}}

# Need a bit of time for the leader to discover itself
sleep 10

echo "Commiting to infrakit"
docker run --rm {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit manager commit {{$groupsURL}}
