#!/bin/sh -xe

_CLIENTNAME=$1
if [ -z $_CLIENTNAME ]; then
  echo "client name is required"
  exit 1
fi
_SEEDJSON=/seed/${_CLIENTNAME}.json
if [ ! -e $_SEEDJSON ]; then
  echo "${_SEEDJSON} is not exists."
  exit 1
fi

_DAYS=`cat ${_SEEDJSON} | jq -r .max_age_days`
_SUBJ=`cat ${_SEEDJSON} | jq -r .subject`
_PRIVATE=/work/$_CLIENTNAME.pem

if [ ! -e $_PRIVATE ]; then
  openssl genrsa -out ${_PRIVATE} 2048
fi
openssl req -new -key ${_PRIVATE} -out ${_CLIENTNAME}.csr -subj "${_SUBJ}"

openssl x509 -req -days ${_DAYS} -in ${_CLIENTNAME}.csr -CA /ca/ca.crt -CAkey /ca/ca.pem -CAcreateserial -CAserial /ca/ca.seq -out ${_CLIENTNAME}.crt
openssl pkcs12 -export -clcerts -in ${_CLIENTNAME}.crt -inkey ${_PRIVATE} -out /out/${_CLIENTNAME}.p12 -passout pass:
