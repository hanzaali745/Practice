#!/usr/bin/env bash
# tls — the reference fix
curl -sv --resolve demo.lab:443:127.0.0.1 --cacert /etc/ssl/lab/ca.crt https://demo.lab/health 2>&1 | grep -i "subject\|match\|error" || true
openssl s_client -connect 127.0.0.1:443 -servername demo.lab < /dev/null 2>/dev/null | openssl x509 -noout -subject -ext subjectAltName -dates
cd /etc/ssl/lab || exit 1
openssl req -newkey rsa:2048 -nodes -subj "/CN=demo.lab" -keyout demo.key -out demo.csr 2> /dev/null
printf 'subjectAltName=DNS:demo.lab\n' > san.ext
openssl x509 -req -in demo.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 90 -extfile san.ext -out demo.crt 2> /dev/null
chmod 600 demo.key
nginx -t && systemctl reload nginx
curl -s --resolve demo.lab:443:127.0.0.1 --cacert /etc/ssl/lab/ca.crt https://demo.lab/health
