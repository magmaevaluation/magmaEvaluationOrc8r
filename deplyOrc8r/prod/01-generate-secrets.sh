#!/usr/bin/env bash

if [ -z "$1" ]
then
  domain=magmalocal.com
else
  domain=$1
fi

echo ""
echo "################"
echo "Creating root CA"
echo "################"
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.pem -subj "/C=US/CN=rootca.$domain"

echo ""
echo "########################"
echo "Creating controller cert"
echo "########################"
openssl genrsa -out controller.key 2048
openssl req -new -key controller.key -out controller.csr -subj "/C=US/CN=*.$domain"


# Create an extension config file
> ${domain}.ext cat <<-EOF
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.$domain
DNS.2 = *.nms.$domain
EOF
openssl x509 -req -in controller.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out controller.crt -days 825 -sha256 -extfile ${domain}.ext

cp controller.crt nms_nginx.pem
cp controller.key nms_nginx.key.pem

echo ""
echo "###########################"
echo "Deleting intermediate files"
echo "###########################"
rm -f controller.csr rootCA.srl ${domain}.ext


echo ""
echo "#########################"
echo "Creating bootstrapper key"
echo "#########################"
openssl genrsa -out bootstrapper.key 2048

echo ""
echo "######################"
echo "Creating fluentd certs"
echo "######################"
openssl genrsa -out fluentd.key 2048
openssl req -x509 -new -nodes -key fluentd.key -sha256 -days 3650 -out fluentd.pem -subj "/C=US/CN=fluentd.$domain"

echo ""
echo "#####################"
echo "Creating certifier CA"
echo "#####################"
openssl genrsa -out certifier.key 2048
openssl req -x509 -new -nodes -key certifier.key -sha256 -days 3650 -out certifier.pem -subj "/C=US/CN=certifier.$domain"

echo ""
echo "############################"
echo "Creating admin_operator cert"
echo "############################"
openssl genrsa -out admin_operator.key.pem 2048
openssl req -new -key admin_operator.key.pem -out admin_operator.csr -subj "/C=US/CN=admin_operator"
openssl x509 -req -in admin_operator.csr -CA certifier.pem -CAkey certifier.key -CAcreateserial -out admin_operator.pem -days 3650 -sha256

# Export to password-protected PKCS12 bundle, e.g. for import into client
# keychain, with the following command
openssl pkcs12 -export -inkey admin_operator.key.pem -in admin_operator.pem -out admin_operator.pfx -password pass:password

echo ""
echo "###########################"
echo "Deleting intermediate files"
echo "###########################"
rm -f admin_operator.csr certifier.srl

