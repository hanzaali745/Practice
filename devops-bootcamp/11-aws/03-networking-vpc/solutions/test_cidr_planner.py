"""python3 -m pytest -q"""
import ipaddress

import pytest

from cidr_planner import plan


def test_two_azs_in_a_16():
    p = plan("10.20.0.0/16", azs=2, prefix=20)
    assert p == {"public": ["10.20.0.0/20", "10.20.16.0/20"], "private": ["10.20.128.0/20", "10.20.144.0/20"]}


def test_subnets_do_not_overlap_and_fit_in_the_vpc():
    vpc = ipaddress.ip_network("10.0.0.0/16")
    nets = [ipaddress.ip_network(n) for tier in plan("10.0.0.0/16", 3, 22).values() for n in tier]
    assert all(n.subnet_of(vpc) for n in nets)
    assert not any(a.overlaps(b) for i, a in enumerate(nets) for b in nets[i + 1:])


@pytest.mark.parametrize("cidr, azs, prefix, message", [
    ("8.8.0.0/16", 2, 20, "not a private"),
    ("10.0.0.0/16", 2, 16, "must be smaller"),
    ("10.0.0.0/24", 3, 26, "only holds"),
])
def test_bad_input_is_rejected(cidr, azs, prefix, message):
    with pytest.raises(ValueError, match=message):
        plan(cidr, azs, prefix)
