{{ source "common.ikt" }}

# Set up infrakit.  This assumes Docker has been installed

mkdir -p /infrakit/plugins /infrakit/configs /infrakit/logs

{{ $bashrc := cat "/home/" (ref "/compute/instance/user") "/.bashrc" | nospace }}
{{ $dockerImage := ref "/infrakit/docker/image" }}
{{ $dockerMounts := ref "/infrakit/docker/options/mount" }}
{{ $dockerEnvs := ref "/infrakit/docker/options/env" }}

echo alias infrakit='docker run --rm {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit' >> {{ $bashrc }}
echo alias infrakit='docker run --rm {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit' >> /root/.bashrc
