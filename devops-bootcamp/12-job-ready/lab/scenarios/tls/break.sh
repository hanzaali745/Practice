# the company's internal CA (in real life its key lives in a vault, not on a web server!)
install -d -m 755 /etc/ssl/lab
cd /etc/ssl/lab || exit 1
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj "/CN=Lab Internal CA" -keyout ca.key -out ca.crt 2> /dev/null
chmod 600 ca.key
# the "renewed" certificate: issued for the WRONG name
openssl req -newkey rsa:2048 -nodes -subj "/CN=www.example.com" -keyout demo.key -out demo.csr 2> /dev/null
printf 'subjectAltName=DNS:www.example.com\n' > san.ext
openssl x509 -req -in demo.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 90 -extfile san.ext -out demo.crt 2> /dev/null
chmod 600 demo.key
cat > /etc/nginx/sites-available/demo-tls <<'EOF'
server {
    listen 443 ssl;
    server_name demo.lab;
    ssl_certificate     /etc/ssl/lab/demo.crt;
    ssl_certificate_key /etc/ssl/lab/demo.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
    }
}
EOF
ln -sf /etc/nginx/sites-available/demo-tls /etc/nginx/sites-enabled/demo-tls
systemctl reload nginx
