import io
import json
from dataclasses import dataclass
from subprocess import run


def get_ts_info() -> json:
    cmd = 'tailscale status --json'
    data = run(cmd, capture_output=True, shell=True)
    j = json.loads(data.stdout.decode('utf-8'))
    with open("sample.json", "w") as f:
        f.write(json.dumps(j, indent=4, sort_keys=True))
    return j

@dataclass
class Host():
    ip: str
    id: str
    host_name: str
    last_seen: str
    online: bool

    @classmethod
    def from_json(cls, data: json):
#        print(f'23: {data}')
        return cls(data['TailscaleIPs'][0], data['ID'], data['HostName'], data["LastSeen"], data["Online"])

data = get_ts_info()

tail_hosts = [Host.from_json(data['Self'])]

for rec in data["Peer"].values():
    tail_hosts.append(Host.from_json(rec))

for h in tail_hosts:
    print(h)

    
