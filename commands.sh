docker build -t mybooks .
docker network create mynet
docker volume create mysqlvolume
docker run --name database -v mysqlvolume:/var/lib/mysql --net mynet --env-file  env.var -d mysql:5.7
docker run --name bookstore --net mynet -p 80:80 mybooks


#running with docker compose
docker-compose up