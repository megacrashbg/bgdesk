CURR_DIR=$(dirname $0)

cd $CURR_DIR

COUNTRY="BR"
STATE="MG"
CITY="Governador Valadares"
ORGANIZATION="Thinksoft LTDA"
ORGANIZATION_UNIT="Boa Gestao"
CN_CA="Thinksof LTDA Certificate Authority"
CN_CERT="Thinksoft"

# This script generates certificates and keys needed for code signing.


# Certificate authority (CA)
openssl genrsa -out ./ca.key 2048
openssl req -new -x509 -nodes -days 5000 -key ./ca.key -out ./ca.crt -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$CN_CA"

# Generate a certificate for code signing, signed by the CA
openssl req -newkey rsa:2048 -nodes -keyout ./sign.key -out ./sign.req -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$CN_CERT"
openssl x509 -req -in ./sign.req -days 398 -CA ./ca.crt -CAkey ./ca.key -set_serial 01 -out ./sign.crt

# Clean up
rm ./sign.req
