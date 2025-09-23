function github-ack
    set git_tip (git rev-parse HEAD)
    set cc_version ($CC --version | head -n 1 | sed 's/ (\(.*\))//')
    set cxx_version ($CXX --version | head -n 1 | sed 's/ (\(.*\))//')

    set configure_command (cat /tmp/bitcoin-core/configure.log | string collect)

    set hostname_info (hostname)
    set uname_m (uname -m)
    set uname_r (uname -r)
    set uname_s (uname -s)

    echo "ACK $git_tip"
    echo ""
    echo "<details>"
    echo "  <summary>system info</summary>"
    echo "  "
    echo "| Key         | Value |"
    echo "|-------------|-------|"
    echo "| Hostname    | $hostname_info |"
    echo "| Arch        | $uname_m |"
    echo "| Kernel      | $uname_r |"
    echo "| System      | $uname_s |"
    echo "| CC          | $cc_version |"
    echo "| CXX         | $cxx_version |"
    echo "  "
    echo "Configuration output:"
    echo "```"
    echo "$configure_command"
    echo "```"
    echo "  "
    echo "</details>"
end
