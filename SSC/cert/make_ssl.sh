#!/bin/bash

echo "Issue a Certificate"
echo "1. RSA Private Key - remember password!! - ex) mm-ssl"
openssl genrsa -aes256 -out $2.key 2048


echo "2. Remove password from Key - input password for ssl"
mv $2.key $2.key.enc
openssl rsa -in $2.key.enc -out $2.key


echo "3. vi $2.conf"
touch $2.conf
echo "[ req ]" | tee -a $2.conf
echo "default_bits            = 2048" | tee -a $2.conf
echo "default_md              = sha1" | tee -a $2.conf
echo "default_keyfile         = $1.key" | tee -a $2.conf
echo "distinguished_name      = req_distinguished_name" | tee -a $2.conf
echo "extensions              = v3_user" | tee -a $2.conf
echo "##req_extensions          = v3_user" | tee -a $2.conf
echo | tee -a $2.conf
echo "[ v3_user ]" | tee -a $2.conf
echo "basicConstraints = CA:FALSE" | tee -a $2.conf
echo "authorityKeyIdentifier  = keyid,issuer" | tee -a $2.conf
echo "subjectKeyIdentifier    = hash" | tee -a $2.conf
echo "keyUsage = nonRepudiation, digitalSignature, keyEncipherment" | tee -a $2.conf
echo | tee -a $2.conf
echo "extendedKeyUsage        = serverAuth,clientAuth" | tee -a $2.conf
echo "subjectAltName          = @alt_names" | tee -a $2.conf
echo | tee -a $2.conf
echo "[ alt_names ]" | tee -a $2.conf
echo "##DNS.1                   = www.mm.com" | tee -a $2.conf
echo "##DNS.2                   = mm.com" | tee -a $2.conf
echo "##DNS.3                   = *.mm.com" | tee -a $2.conf
echo "IP.1                    = $2" | tee -a $2.conf
echo "IP.2                    = 127.0.0.1" | tee -a $2.conf
echo | tee -a $2.conf
echo "[ req_distinguished_name ]" | tee -a $2.conf
echo "countryName                    = Country Name (2 letter code)" | tee -a $2.conf
echo "countryName_default            = US" | tee -a $2.conf
echo "countryName_min                = 2" | tee -a $2.conf
echo "countryName_max                = 2" | tee -a $2.conf
echo | tee -a $2.conf
echo "organizationName               = Organization Name (eg, company)" | tee -a $2.conf
echo "organizationName_default       = Mike and Mary" | tee -a $2.conf
echo | tee -a $2.conf
echo "organizationalUnitName         = Organizational Unit Name (eg, section)" | tee -a $2.conf
echo "organizationalUnitName_default = MM SSL Project" | tee -a $2.conf
echo | tee -a $2.conf
echo "commonName                     = Common Name (eg, your name or your server's hostname)" | tee -a $2.conf
echo "commonName_default             = We are Mike and Mary" | tee -a $2.conf
echo "commonName_max                 = 64" | tee -a $2.conf


echo "4. CSR - enter default value set in $2.conf"
openssl req -new -key $2.key -out $2.csr -config $2.conf


echo "5. SSL Certificate for $2 - input password for root ca"
openssl x509 -req -days 1825 -extensions v3_user -in $2.csr \
-CA $1.crt -CAcreateserial \
-CAkey  $1.key \
-out $2.crt -extfile $2.conf


echo "6. Check SSL Certificate"
openssl x509 -text -in $2.crt


echo "7. Check CSR"
openssl req -text -in $2.csr


echo "Configure Nginx"
echo "1. sudo vi /etc/nginx/sites-available/https"
echo "=================="
echo "server {"
echo "    listen                  443 ssl;"
echo "    server_name             _;"
echo "    ssl_certificate         /home/dave/www/ca/$2.crt;"
echo "    ssl_certificate_key     /home/dave/www/ca/$2.key;"
echo "    ssl_session_cache       shared:SSL:1m;"
echo "    ssl_session_timeout     5m;"
echo ""
echo "    ssl_ciphers HIGH:!aNULL:!MD5;"
echo "    ssl_prefer_server_ciphers    on;"
echo ""
echo "    location / {"
echo "        root        /home/dave/www/ca;"
echo "        index       index.html index.htm;"
echo "    }"
echo "}"
echo "=================="


echo "2. Symbolic link"
echo "ln -s /etc/nginx/sites-available/https /etc/nginx/sites-enabled/https"


echo "3. nginx -> nodejs"
openssl rsa -in $2.key -text > private.pem
openssl x509 -inform PEM -in $2.crt > public.pem

echo "const server = https.createServer({"
echo "    key: fs.readFileSync('/home/dave/www/ca/private.pem'),"
echo "    cert: fs.readFileSync('/home/dave/www/ca/public.pem'),"
echo "    passphrase: 'mm-ssl'"
echo "}, app);"
