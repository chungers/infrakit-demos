#!/bin/bash

{{ source "common.ikt" }}

# Set up infrakit.  This assumes Docker has been installed
{{ include "infrakit.sh" }}

{{ $dockerImage := ref "/infrakit/docker/image" }}
{{ $dockerMounts := ref "/infrakit/docker/options/mount" }}
{{ $dockerEnvs := ref "/infrakit/docker/options/env" }}
{{ $pluginsURL := cat (ref "/cluster/config/urlRoot") "/plugins.json" | nospace }}
{{ $groupsURL := cat (ref "/cluster/config/urlRoot") "/groups.json" | nospace }}

echo "Starting up infrakit"

docker run -d --name ensemble {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} \
       infrakit plugin start --wait --config-url {{$pluginsURL}} --exec os --log 5 \
       manager \
       group-stateless \
       flavor-swarm

echo "Starting up instance-aws plugin"
docker run -d --name instance-aws {{$dockerMounts}} {{$dockerEnvs}} infrakit/aws:dev \
       infrakit-instance-aws --log 5

# Need a bit of time for the leader to discover itself
sleep 20

echo "Commiting to infrakit"
docker run --rm {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} \
       infrakit manager commit {{$groupsURL}}
