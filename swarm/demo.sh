{{ source "common.ikt" }}

# Set up infrakit.  This assumes Docker has been installed
{{ include "infrakit.sh" }}

# For N+1 case, we use leader file and not swarm
echo group > {{ref "/infrakit/home"}}/leader


echo "Starting up infrakit"

docker run -d --rm --name ensemble {{$dockerMounts}} {{$dockerEnvs}} {{$dockerImage}} infrakit plugin start \
       --wait --config-url {{$pluginsURL}} --exec os --log 5 \
       manager \
       group-stateless \
       flavor-swarm

echo "Starting up instance-aws plugin"
docker run -d --rm --name instance-aws {{$dockerMounts}} {{$dockerEnvs}} infrakit/aws:dev infrakit-instance-aws \
       infrakit-instance-aws --log 5
