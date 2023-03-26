# fabric-zkp-backend
## Introduction
This repo contains the script and configurations to launch a 2-orgs hlf network.

## Getting Started
Generate docker-compose for 10 peers network
``` sh
chmod +x ./compose-files/generate.sh
./compose-files/generate.sh 10
```

Launch network
```sh
./raiseNetwork.sh
```


shutdown and clean 
```sh 
./clean.sh
```