trusted() { curl -sf --max-time 5 --resolve demo.lab:443:127.0.0.1 --cacert /etc/ssl/lab/ca.crt https://demo.lab/health; }
valid_30_days() {
    openssl s_client -connect 127.0.0.1:443 -servername demo.lab < /dev/null 2> /dev/null | openssl x509 -noout -checkend 2592000
}
key_private() { (( (0$(stat -c %a /etc/ssl/lab/demo.key) & 4) == 0 )); }
ok "the nginx config is valid" nginx -t
ok "https://demo.lab is trusted (lab CA) and answers" trusted
ok "the certificate stays valid for 30+ days" valid_30_days
ok "the private key is not readable by everyone" key_private
ok "users get the real app through nginx" app_healthy
finish
