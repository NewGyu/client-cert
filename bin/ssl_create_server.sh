#!/bin/sh -xe

_SERVERNAME=$1
_SEEDJSON=/seed/${_SERVERNAME}.json

_DAYS=`cat ${_SEEDJSON} | jq -r .max_age_days`
_SUBJ=`cat ${_SEEDJSON} | jq -r .subject`
_PRIVATE=/out/$_SERVERNAME.pem

if [ -z $_SERVERNAME ]; then
  echo "client name is required"
  exit 1
fi
if [ ! -e $_SEEDJSON ]; then
  echo "${_SEEDJSON} is not exists."
  exit 1
fi

if [ ! -e $_PRIVATE ]; then
  openssl genrsa -out $_PRIVATE 2048
fi
cp /etc/ssl/openssl.cnf /work/openssl.cnf
echo "\n[ SAN ]\nsubjectAltName = DNS:${_SERVERNAME}\n" >> /work/openssl.cnf
openssl req -new \
  -config /work/openssl.cnf -reqexts SAN \
  -key $_PRIVATE -out ${_SERVERNAME}.csr -sha256 -subj "${_SUBJ}"

echo "subjectAltName=DNS:${_SERVERNAME}\n" >> /work/x509.ext
openssl x509 -req -in ${_SERVERNAME}.csr \
  -days ${_DAYS} -extfile /work/x509.ext \
  -CA /ca/ca.crt -CAkey /ca/ca.pem -CAcreateserial -CAserial /ca/ca.seq \
  -out /out/${_SERVERNAME}.crt
cat /ca/ca.crt >> /out/${_SERVERNAME}.crt
