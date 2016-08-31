#!/bin/bash

rm -f *.pem
rm -f *.csr

HOST="core-01"
IP="IP:172.17.8.101,IP:172.17.8.102,IP:172.17.8.103,IP:127.0.0.1"

openssl genrsa -aes256 -passout pass:docker -out ca-key.pem 4096

openssl req -subj "//CN=$HOST" -new -x509 -days 365 -key ca-key.pem -sha256 -passin pass:docker -out ca.pem

openssl genrsa -out server-key.pem 4096

openssl req -subj "//CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = $IP > extfile.cnf

openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -passin pass:docker -out server-cert.pem -extfile extfile.cnf
  
openssl genrsa -out key.pem 4096

openssl req -subj '//CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth > extfile.cnf

openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -passin pass:docker -out cert.pem -extfile extfile.cnf
  
chmod -v 0400 ca-key.pem key.pem server-key.pem

chmod -v 0444 ca.pem server-cert.pem cert.pem