# a config-management run pushed the resolver of ANOTHER data centre to this box
cp /etc/resolv.conf /etc/resolv.conf.bak-docker
printf '# managed by config management — DC2 resolvers\nnameserver 192.0.2.53\noptions timeout:1 attempts:1\n' > /etc/resolv.conf
rm /etc/resolv.conf.bak-docker      # ...and nobody kept the original
systemctl restart demo-app
