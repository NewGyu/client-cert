#!/bin/sh -xe

_SEEDJSON=/ca/ca.json
if [ ! -e $_SEEDJSON ]; then
  echo "${_SEEDJSON} is not exists."
  exit 1
fi

_DAYS=`cat ${_SEEDJSON} | jq -r .max_age_days`
_SUBJ=`cat ${_SEEDJSON} | jq -r .subject`
_PRIVATE=/ca/ca.pem
_CERT=/ca/ca.crt
_CRL=/ca/ca.crl

if [ ! -e $_PRIVATE ]; then
  openssl genrsa -out ${_PRIVATE} 2048
fi
openssl req -new -x509 -days ${_DAYS} -key ${_PRIVATE} -out ${_CERT} -subj "${_SUBJ}"
openssl ca -name CA_default -gencrl -keyfile ${_PRIVATE} -cert ${_CERT} -out ${_CRL} -crldays ${_DAYS}
