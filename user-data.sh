#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt-get install unattended-upgrades apache2  -y
sudo apt install snapd -y
sudo snap install --classic certbot
sleep 10
sudo snap set certbot trust-plugin-with-root=ok
sudo snap install --beta certbot-dns-cloudflare

sudo service apache2 restart
sudo a2enmod ssl
sudo a2enmod rewrite

sudo touch /home/ubuntu/cloudFlareUpdateDDNSCronTask.sh
sudo cat <<EOF > /home/ubuntu/cloudFlareUpdateDDNSCronTask.sh
#!/bin/sh
[ ! -f /var/tmp/current_ip.txt ] && touch /var/tmp/currentip.txt
NEWIP="\$(dig +short myip.opendns.com @resolver1.opendns.com)"
CURRENTIP="\$(cat /var/tmp/currentip.txt)"
if [ "\$NEWIP" = "\$CURRENTIP" ]
then
  echo "IP address unchanged"
else
  curl -X PUT "https://api.cloudflare.com/client/v4/zones/${cloudflareZone}/dns_records/${cloudflareDNSRecord}" \
    -H "X-Auth-Email: ${X-Auth-Email}" \
    -H "X-Auth-Key: ${X-Auth-Key}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"${CloudFlareDNSDomain}\",\"content\":\"\$NEWIP\",\"proxied\":true}"
  echo \$NEWIP > /var/tmp/currentip.txt
fi
EOF
sudo chmod +x /home/ubuntu/cloudFlareUpdateDDNSCronTask.sh
sudo sh /home/ubuntu/cloudFlareUpdateDDNSCronTask.sh

cd /var/www/html
# sudo touch /var/www/html/.htaccess
# sudo chown :www-data /var/www/html/.htaccess
# sudo chmod 664 /var/www/html/.htaccess
sudo mkdir /home/ubuntu/ssl
~$ sudo chgrp www-data /var/www/html/
sudo chmod 775 /var/www/html/
sudo chmod g+s /var/www/html/
sudo useradd -G www-data ubuntu
sudo chown ubuntu /var/www/html


sudo rm -f /var/www/html/index.html
cd /home/ubuntu
git clone https://github.com/mattiaborsoi/public-website #change this with your GitHub repo with the website source code
sudo mv /home/ubuntu/public-website/* /var/www/html
rm -f -r /home/ubuntu/public-website
sudo rm -f /var/www/html/README.md

sudo mkdir /home/ubuntu/.secrets
sudo chmod 0700 /home/ubuntu/.secrets/
sudo touch /home/ubuntu/.secrets/cloudflare.ini
sudo chmod 0400 /home/ubuntu/.secrets/cloudflare.ini
sudo cat <<EOF > /home/ubuntu/.secrets/cloudflare.ini
# Cloudflare API token used by Certbot
dns_cloudflare_email = ${X-Auth-Email}
dns_cloudflare_api_key = ${X-Auth-Key}
EOF
sudo certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /home/ubuntu/.secrets/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 120 \
    -d ${CloudFlareDNSDomain}  \
    -d www.${CloudFlareDNSDomain} \
    --preferred-challenges dns-01 \
    --non-interactive --agree-tos \
    -m ${X-Auth-Email}

sudo cat <<EOF > /home/ubuntu/ssl/origin-pull-ca.pem 
-----BEGIN CERTIFICATE-----
MIIGCjCCA/KgAwIBAgIIV5G6lVbCLmEwDQYJKoZIhvcNAQENBQAwgZAxCzAJBgNV
BAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMRQwEgYDVQQLEwtPcmln
aW4gUHVsbDEWMBQGA1UEBxMNU2FuIEZyYW5jaXNjbzETMBEGA1UECBMKQ2FsaWZv
cm5pYTEjMCEGA1UEAxMab3JpZ2luLXB1bGwuY2xvdWRmbGFyZS5uZXQwHhcNMTkx
MDEwMTg0NTAwWhcNMjkxMTAxMTcwMDAwWjCBkDELMAkGA1UEBhMCVVMxGTAXBgNV
BAoTEENsb3VkRmxhcmUsIEluYy4xFDASBgNVBAsTC09yaWdpbiBQdWxsMRYwFAYD
VQQHEw1TYW4gRnJhbmNpc2NvMRMwEQYDVQQIEwpDYWxpZm9ybmlhMSMwIQYDVQQD
ExpvcmlnaW4tcHVsbC5jbG91ZGZsYXJlLm5ldDCCAiIwDQYJKoZIhvcNAQEBBQAD
ggIPADCCAgoCggIBAN2y2zojYfl0bKfhp0AJBFeV+jQqbCw3sHmvEPwLmqDLqynI
42tZXR5y914ZB9ZrwbL/K5O46exd/LujJnV2b3dzcx5rtiQzso0xzljqbnbQT20e
ihx/WrF4OkZKydZzsdaJsWAPuplDH5P7J82q3re88jQdgE5hqjqFZ3clCG7lxoBw
hLaazm3NJJlUfzdk97ouRvnFGAuXd5cQVx8jYOOeU60sWqmMe4QHdOvpqB91bJoY
QSKVFjUgHeTpN8tNpKJfb9LIn3pun3bC9NKNHtRKMNX3Kl/sAPq7q/AlndvA2Kw3
Dkum2mHQUGdzVHqcOgea9BGjLK2h7SuX93zTWL02u799dr6Xkrad/WShHchfjjRn
aL35niJUDr02YJtPgxWObsrfOU63B8juLUphW/4BOjjJyAG5l9j1//aUGEi/sEe5
lqVv0P78QrxoxR+MMXiJwQab5FB8TG/ac6mRHgF9CmkX90uaRh+OC07XjTdfSKGR
PpM9hB2ZhLol/nf8qmoLdoD5HvODZuKu2+muKeVHXgw2/A6wM7OwrinxZiyBk5Hh
CvaADH7PZpU6z/zv5NU5HSvXiKtCzFuDu4/Zfi34RfHXeCUfHAb4KfNRXJwMsxUa
+4ZpSAX2G6RnGU5meuXpU5/V+DQJp/e69XyyY6RXDoMywaEFlIlXBqjRRA2pAgMB
AAGjZjBkMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgECMB0GA1Ud
DgQWBBRDWUsraYuA4REzalfNVzjann3F6zAfBgNVHSMEGDAWgBRDWUsraYuA4REz
alfNVzjann3F6zANBgkqhkiG9w0BAQ0FAAOCAgEAkQ+T9nqcSlAuW/90DeYmQOW1
QhqOor5psBEGvxbNGV2hdLJY8h6QUq48BCevcMChg/L1CkznBNI40i3/6heDn3IS
zVEwXKf34pPFCACWVMZxbQjkNRTiH8iRur9EsaNQ5oXCPJkhwg2+IFyoPAAYURoX
VcI9SCDUa45clmYHJ/XYwV1icGVI8/9b2JUqklnOTa5tugwIUi5sTfipNcJXHhgz
6BKYDl0/UP0lLKbsUETXeTGDiDpxZYIgbcFrRDDkHC6BSvdWVEiH5b9mH2BON60z
0O0j8EEKTwi9jnafVtZQXP/D8yoVowdFDjXcKkOPF/1gIh9qrFR6GdoPVgB3SkLc
5ulBqZaCHm563jsvWb/kXJnlFxW+1bsO9BDD6DweBcGdNurgmH625wBXksSdD7y/
fakk8DagjbjKShYlPEFOAqEcliwjF45eabL0t27MJV61O/jHzHL3dknXeE4BDa2j
bA+JbyJeUMtU7KMsxvx82RmhqBEJJDBCJ3scVptvhDMRrtqDBW5JShxoAOcpFQGm
iYWicn46nPDjgTU0bX1ZPpTpryXbvciVL5RkVBuyX2ntcOLDPlZWgxZCBp96x07F
AnOzKgZk4RzZPNAxCXERVxajn/FLcOhglVAKo5H0ac+AitlQ0ip55D2/mf8o72tM
fVQ6VpyjEXdiIXWUq/o=
-----END CERTIFICATE-----
EOF

sudo cat <<EOF > /etc/apache2/sites-available/${CloudFlareDNSDomain}.conf
<VirtualHost *:80>
	ServerAdmin ${X-Auth-Email}
	ServerName ${CloudFlareDNSDomain}
	ServerAlias www.${CloudFlareDNSDomain}
    RedirectMatch permanent ^/(.*)\$ https://${CloudFlareDNSDomain}/\$1
</VirtualHost>
<VirtualHost *:443>
        ServerAdmin ${X-Auth-Email}
        ServerName ${CloudFlareDNSDomain}
        ServerAlias www.${CloudFlareDNSDomain}
        DocumentRoot /var/www/html
        ErrorLog /var/log/apache2/error.log
        CustomLog /var/log/apache2/access.log combined
        SSLEngine on
        SSLCertificateFile /etc/letsencrypt/live/${CloudFlareDNSDomain}/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/${CloudFlareDNSDomain}/privkey.pem
        SSLCACertificateFile /home/ubuntu/ssl/origin-pull-ca.pem
</VirtualHost>
ServerSignature Off
ServerTokens Prod
EOF
sudo a2ensite ${CloudFlareDNSDomain}.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

