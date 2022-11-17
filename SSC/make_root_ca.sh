#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "ex) bash make_root_ca.sh root-ca"
    exit 1
fi


echo "Create Root CA"
echo "1. RSA key - remember password!! - ex) mm-root-ca"
openssl genrsa -aes256 -out $1.key 2048


echo "2. vi $1.conf"
touch $1.conf
echo "[ req ]" | tee -a $1.conf
echo "default_bits            = 2048" | tee -a $1.conf
echo "default_md              = sha1" | tee -a $1.conf
echo "default_keyfile         = $1.key" | tee -a $1.conf
echo "distinguished_name      = req_distinguished_name" | tee -a $1.conf
echo "extensions              = v3_ca" | tee -a $1.conf
echo "req_extensions          = v3_ca" | tee -a $1.conf
echo | tee -a $1.conf
echo "[ v3_ca ]" | tee -a $1.conf
echo "basicConstraints       = critical, CA:TRUE, pathlen:0" | tee -a $1.conf
echo "subjectKeyIdentifier   = hash" | tee -a $1.conf
echo "##authorityKeyIdentifier = keyid:always, issuer:always" | tee -a $1.conf
echo "keyUsage               = keyCertSign, cRLSign" | tee -a $1.conf
echo "nsCertType             = sslCA, emailCA, objCA" | tee -a $1.conf
echo | tee -a $1.conf
echo "[ req_distinguished_name ]" | tee -a $1.conf
echo "countryName                     = Country Name (2 letter code)" | tee -a $1.conf
echo "countryName_default             = AU" | tee -a $1.conf
echo "countryName_min                 = 2" | tee -a $1.conf
echo "countryName_max                 = 2" | tee -a $1.conf
echo | tee -a $1.conf
echo "organizationName                = Organization Name (eg, company)" | tee -a $1.conf
echo "organizationName_default        = Mike and Mary" | tee -a $1.conf
echo | tee -a $1.conf
echo "#organizationalUnitName         = Organizational Unit Name (eg, section)" | tee -a $1.conf
echo "#organizationalUnitName_default = CA Project" | tee -a $1.conf
echo | tee -a $1.conf
echo "commonName                      = Common Name (eg, your name or your server's hostname)" | tee -a $1.conf
echo "commonName_default              = MM Self Signed CA" | tee -a $1.conf
echo "commonName_max                  = 64" | tee -a $1.conf


echo "3. CSR - input password for root ca - enter default value set in $1.conf"
openssl req -new -key $1.key -out $1.csr -config $1.conf


echo "4. Self Signed Certificate - input password for root ca"
openssl x509 -req \
-days 3650 \
-extensions v3_ca \
-set_serial 1 \
-in $1.csr \
-signkey $1.key \
-out $1.crt \
-extfile $1.conf


echo "5. Check Root CA"
openssl x509 -text -in $1.crt


echo "$1.key : Root CA private key"
echo "$1.crt : Root CA public key"
