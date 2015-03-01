Readme.txt

# To build the docker, run the following command from the directory where the Dockerfile is located
docker build .

# To run the container with a static name
docker run -p 3306 --name <blogs-mysql> -e MY_SQL_ROOT_PASSWORD=<root-password-for-mysql>  -d mysql

# To run the wordpress with a link to My SQL, use following pattern to run the container with the link.
# Do not change the alias 'mysql' in the link, since that would be used in the wordpress container to autodiscover mysql
docker run --link <blogs-mysql>:mysql -p 8080:80 --name <blogs-wordpress> -e WORDPRESS_DB_PASSWORD=<root-password-for-mysql>  -d wordpress

