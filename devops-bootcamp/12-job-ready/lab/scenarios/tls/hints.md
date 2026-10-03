## Hint 1
Let the client tell you what's wrong:
`curl -v --resolve demo.lab:443:127.0.0.1 --cacert /etc/ssl/lab/ca.crt https://demo.lab/health`.
Then look at the certificate itself: `openssl s_client -connect 127.0.0.1:443 -servername demo.lab < /dev/null | openssl x509 -noout -subject -ext subjectAltName -dates`.

## Hint 2
Browsers check the **Subject Alternative Name**, not the CN. Which names is the certificate valid for? Which name do
users type? A new certificate is needed: key + CSR for `demo.lab`, signed by the lab CA in `/etc/ssl/lab/`.

## Hint 3
```bash
cd /etc/ssl/lab
openssl req -newkey rsa:2048 -nodes -subj "/CN=demo.lab" -keyout demo.key -out demo.csr
printf 'subjectAltName=DNS:demo.lab\n' > san.ext
openssl x509 -req -in demo.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 90 -extfile san.ext -out demo.crt
nginx -t && systemctl reload nginx
```
Then repeat the `curl` from hint 1. Bonus: how would you get **alerted** 30 days before a certificate expires?
