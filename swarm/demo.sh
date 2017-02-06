{{ source "common.ikt" }}

# Set up infrakit.  This assumes Docker has been installed

mkdir -p /infrakit/plugins /infrakit/configs /infrakit/logs

{{ $bashrc := cat "/home/" (ref "/compute/instance/user") "/.bashrc" | nospace }}
{{ $dockerImage := ref "/infrakit/docker/image" }}
{{ $dockerMounts := ref "/infrakit/docker/options/mount" }}
{{ $dockerEnvs := ref "/infrakit/docker/options/env" }}
{{ $pluginsURL := cat (ref "/cluster/config/urlRoot") "plugins.json" | nospace }}

echo "alias infrakit='docker run --rm {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit'" >> {{ $bashrc }}

echo "Starting up infraktit"

docker run -d --name infrakit {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit plugin start \
       --wait --config-url {{$pluginsURL}} --exec os \
       manager group-stateless flavor-swarm --log 5
