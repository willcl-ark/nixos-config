function podman-usage
    set -l network_name $argv[1]

    if test -z "$network_name"
        echo "Usage: podman-usage <NETWORK_NAME>"
        return 1
    end

    set -l container_names (podman ps --filter network=$network_name --format '{{.Names}}')

    if not set -q container_names[1]
        echo "No containers found on network $network_name"
        return 1
    end

    podman stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}}" $container_names | awk -F, '{gsub(/%/, "", $2); gsub(/\/.*/, "", $3); sum1+=$2; sum2+=$3} END{print "CPU: " sum1 "%, MEM: " sum2 "MiB"}'
end
