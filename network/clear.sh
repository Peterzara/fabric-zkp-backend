docker-compose -f compose-files/docker-compose.yml kill \
&& docker-compose -f compose-files/docker-compose.yml down


docker rm $(docker ps -f "name=.sample.com-" -aq)
docker rmi $(docker images -f "reference=dev-*sample.com*" -q)

docker exec fabric_host_sample.com rm -rf config fabric crypto-config
 

docker kill fabric_host_sample.com 
docker rm fabric_host_sample.com

rm -r ../client/hlf-voting-sample/users
docker volume rm $(docker volume ls -q)