#!/bin/bash

# Define the number of peer and CouchDB services to create
num_peers=$1

# Generate the YAML file
cat <<EOF >docker-compose.yml
version: '2'

networks:
  basic:

services:
  ca.sample.com:
    container_name: ca.sample.com
    extends:
      file: base.yaml
      service: ca-base
    environment:
      - FABRIC_CA_SERVER_CA_NAME=ca.sample.com
    ports:
      - 58054:7054
    volumes:
      - ./../crypto-config/peerOrganizations/org1.sample.com/ca/:/etc/hyperledger/fabric-ca-server-config
    networks:
      - basic

  ca2.sample.com:
    container_name: ca2.sample.com
    extends:
      file: base.yaml
      service: ca-base
    environment:
      - FABRIC_CA_SERVER_CA_NAME=ca2.sample.com
    ports:
      - 59054:7054
    volumes:
      - ./../crypto-config/peerOrganizations/org2.sample.com/ca/:/etc/hyperledger/fabric-ca-server-config
    networks:
      - basic

  orderer1.sample.com:
    container_name: orderer1.sample.com
    extends:
      file: base.yaml
      service: orderer-base
    environment:
      - ORDERER_GENERAL_LOCALMSPID=Orderer1MSP
    ports:
      - 57050:7050
    volumes:
        - ./../crypto-config/ordererOrganizations/sample.com/orderers/orderer1.sample.com/msp:/var/hyperledger/orderer/msp
        - ./../crypto-config/ordererOrganizations/sample.com/orderers/orderer1.sample.com/tls:/var/hyperledger/orderer/tls
    networks:
      - basic

  cli.sample.com:  
    container_name: cli.sample.com
    extends:
      file: base.yaml
      service: cli-base
    networks:
        - basic

EOF

# Generate the peer services
for ((i=0; i<$num_peers; i++)); do
  cat <<EOF >>docker-compose.yml
  peer$i.org1.sample.com:
    container_name: peer$i.org1.sample.com
    extends:
      file: base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer$i.org1.sample.com
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
      - CORE_PEER_ADDRESS=peer$i.org1.sample.com:7051
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb.sample.com$i:5984
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer$i.org1.sample.com:7051
    ports:
      - $((7051+i)):7051
      - $((7253+i)):7053
    volumes:
      - ./../crypto-config/peerOrganizations/org1.sample.com/peers/peer$i.org1.sample.com/msp:/etc/hyperledger/fabric/msp
      - ./../crypto-config/peerOrganizations/org1.sample.com/peers/peer$i.org1.sample.com/tls:/etc/hyperledger/fabric/tls
    depends_on:
      - couchdb.sample.com$i
    networks:
      - basic

  peer$i.org2.sample.com:
    container_name: peer$i.org2.sample.com
    extends:
      file: base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer$i.org2.sample.com
      - CORE_PEER_LOCALMSPID=Org2MSP
      - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
      - CORE_PEER_ADDRESS=peer$i.org2.sample.com:7051
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb2.sample.com$i:5984
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer$i.org2.sample.com:7051
    ports:
      - $((9051+i)):7051
      - $((9253+i)):7053
    volumes:
      - ./../crypto-config/peerOrganizations/org2.sample.com/peers/peer$i.org2.sample.com/msp:/etc/hyperledger/fabric/msp
      - ./../crypto-config/peerOrganizations/org2.sample.com/peers/peer$i.org2.sample.com/tls:/etc/hyperledger/fabric/tls
    depends_on:
      - couchdb2.sample.com$i
    networks:
      - basic

EOF
done

# Generate the CouchDB services
for ((i=0; i<$num_peers; i++)); do
  cat <<EOF >>docker-compose.yml
  couchdb.sample.com$i:
    container_name: couchdb.sample.com$i
    image: hyperledger/fabric-couchdb:\${THIRD_PARTY_VERSION}
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=
    ports:
      - $((55984+i)):5984
    networks:
      - basic

  couchdb2.sample.com$i:
    container_name: couchdb2.sample.com$i
    image: hyperledger/fabric-couchdb:\${THIRD_PARTY_VERSION}
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=
    ports:
      - $((56984+i)):5984
    networks:
      - basic

EOF
done
