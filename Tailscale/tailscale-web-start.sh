#!/usr/bin/env bash

declare res

read res <<< $(tailscale status)
if [[ "$res" == "Tailscale is stopped." ]]; then
        printf 'tailscale down, trying to start\n' | systemd-cat
        exec tailscale up &
fi

read ip <<< $(tailscale ip)
printf 'starting web server for current ip: %s\n' "$ip" | systemd-cat
exec tailscale web --readonly --listen "$ip":9091 &
