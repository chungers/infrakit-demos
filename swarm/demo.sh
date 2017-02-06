{{ source "common.ikt" }}

# Set up infrakit.  This assumes Docker has been installed

mkdir -p /infrakit/plugins /infrakit/configs /infrakit/logs

# For N+1 case, we use leader file and not swarm
echo group > /infrakit/leader

{{ $bashrc := cat "/home/" (ref "/compute/instance/user") "/.bashrc" | nospace }}
{{ $dockerImage := ref "/infrakit/docker/image" }}
{{ $dockerMounts := ref "/infrakit/docker/options/mount" }}
{{ $dockerEnvs := ref "/infrakit/docker/options/env" }}
{{ $pluginsURL := cat (ref "/cluster/config/urlRoot") "plugins.json" | nospace }}

echo "alias infrakit='docker run --rm {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit'" >> {{ $bashrc }}

echo "Starting up infrakit"

docker run -d --rm --name ensemble {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit plugin start \
       --wait --config-url {{$pluginsURL}} --exec os --log 5 \
       manager \
       group-stateless \
       flavor-swarm

echo "Starting up instance-aws plugin"
docker run -d --rm --name instance-aws {{$dockerMounts}} {{$dockerEnvs}} infrakit/aws:dev \
       infrakit-instance-aws --log 5
