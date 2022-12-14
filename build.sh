#!/bin/bash

[[ -z "${path}" ]] && path="/ws"

[[ -z "${fake-web}" ]] && fake-web="alist.nn.ci"

#ver=$(wget -qO- "https://api.github.com/repos/txthinking/brook/releases/latest" | sed -n -r -e 's/.*"tag_name".+?"([vV0-9\.]+?)".*/\1/p')
#[[ -z "${ver}" ]] && ver="v20210601"
#brook_latest="https://github.com/txthinking/brook/releases/download/$ver/brook_linux_amd64"
#brook_latest="https://github.com/txthinking/brook/releases/latest/download/brook_linux_amd64"

#wget --no-check-certificate https://github.com/txthinking/brook/releases/latest/download/brook_linux_amd64

wget --no-check-certificate https://github.com/txthinking/brook/releases/latest/download/brook_linux_amd64 -O /usr/local/bin/brook
chmod +x /usr/local/bin/brook

# Run brook
/usr/local/bin/brook wsserver -l :1080 --password ${password} --path ${path} &

# generate a Brook link and a QR code
#mkdir /root/$password
#brook_link=$(./brook_linux_amd64 link -s wss://${app_name}.herokuapp.com:443${path} -p $password | tr -d "\n")
#echo -n "${brook_link}" >/root/$password/link.txt
#echo -n "${brook_link}" | qrencode -s 6 -o /root/$password/qr.png
#echo -n "The Brook link is ${brook_link}"

#write brook.conf
cat >/etc/nginx/conf.d/brook.conf <<EOF
 upstream backServer{
    server 127.0.0.1:5238;
 }
server {
        listen       80;
        server_name  localhost;

    root /root;
    resolver 8.8.8.8:53;

    location / {
        location / {
            proxy_redirect                      off;
            proxy_pass                          http://127.0.0.1:5238;
            proxy_http_version                  1.1;

            # 指定头部：
            proxy_set_header  Upgrade           \$http_upgrade;
            proxy_set_header  Connection        "upgrade";
            proxy_set_header  Host              \$http_host;
            proxy_read_timeout  300s;
            # Show realip in access.log
            proxy_set_header  X-Real-IP         \$remote_addr;
            proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
        }


    location = ${path} {
        if (\$http_upgrade != "websocket") {
            return 404;
        }
            proxy_redirect                      off;
            proxy_pass                          http://127.0.0.1:1080;
            proxy_http_version                  1.1;

            # 指定头部：
            proxy_set_header  Upgrade           \$http_upgrade;
            proxy_set_header  Connection        "upgrade";
            proxy_set_header  Host              \$http_host;
            proxy_read_timeout  300s;
            # Show realip in access.log
            proxy_set_header  X-Real-IP         \$remote_addr;
            proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
        }

    location /$password {
        root /root;
    }
  }
}
EOF

#download&run panindex
wget --no-check-certificate https://github.com/libsgh/PanIndex/releases/latest/download/PanIndex-linux-amd64.tar.gz -O panindex.tar.gz
tar -zxvf panindex.tar.gz
mv PanIndex-linux-amd64 panindex
rm -f panindex.tar.gz & rm -f LICENSE
/panindex &

echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo "Server:   wss://your-domain:443${path}"
echo "Password: $password"
echo ////////////////////////////////////////////////////

rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
