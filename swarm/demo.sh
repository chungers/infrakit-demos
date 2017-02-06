{{ source "common.ikt" }}

# Set up infrakit.  This assumes Docker has been installed
{{ include "infrakit.sh" }}

# For N+1 case, we use leader file and not swarm
echo group > {{ref "/infrakit/home"}}/leader

{{ $dockerImage := ref "/infrakit/docker/image" }}
{{ $dockerMounts := ref "/infrakit/docker/options/mount" }}
{{ $dockerEnvs := ref "/infrakit/docker/options/env" }}
{{ $pluginsURL := cat (ref "/cluster/config/urlRoot") "/plugins.json" | nospace }}

echo "Starting up infrakit"

docker run -d --name ensemble {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} \
       infrakit plugin start --wait --config-url {{$pluginsURL}} --exec os --log 5 \
       manager \
       group-stateless \
       flavor-swarm

echo "Starting up instance-aws plugin"
docker run -d --name instance-aws {{$dockerMounts}} {{$dockerEnvs}} infrakit/aws:dev \
       infrakit-instance-aws --log 5
