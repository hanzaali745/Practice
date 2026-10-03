"""cidr_planner.py — split a VPC CIDR into public and private subnets across availability zones.

Usage: python3 cidr_planner.py 10.20.0.0/16 --azs 2 --prefix 20
Prints a table and JSON you could feed to Terraform. Leaves free space for later (databases, more AZs).
"""
import argparse
import ipaddress
import json


def plan(vpc_cidr: str, azs: int, prefix: int) -> dict[str, list[str]]:
    vpc = ipaddress.ip_network(vpc_cidr, strict=True)
    if not vpc.is_private:
        raise ValueError(f"{vpc} is not a private (RFC 1918) range")
    if prefix <= vpc.prefixlen:
        raise ValueError(f"subnets (/{prefix}) must be smaller than the VPC (/{vpc.prefixlen})")
    subnets = list(vpc.subnets(new_prefix=prefix))
    if len(subnets) < 2 * azs:
        raise ValueError(f"/{vpc.prefixlen} only holds {len(subnets)} subnets of /{prefix}, need {2 * azs}")
    # public subnets first, private subnets in the second half: easy to recognise by eye
    half = len(subnets) // 2
    return {"public": [str(s) for s in subnets[:azs]], "private": [str(s) for s in subnets[half:half + azs]]}


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("cidr")
    p.add_argument("--azs", type=int, default=2)
    p.add_argument("--prefix", type=int, default=20)
    a = p.parse_args()
    result = plan(a.cidr, a.azs, a.prefix)
    hosts = ipaddress.ip_network(result["public"][0]).num_addresses - 5        # AWS reserves 5 per subnet
    print(f"{'tier':8} {'AZ':3} {'subnet':18} usable IPs")
    for tier in ("public", "private"):
        for i, net in enumerate(result[tier]):
            print(f"{tier:8} {chr(97 + i):3} {net:18} {hosts}")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
