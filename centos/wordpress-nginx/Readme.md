sudo docker run --name blogs-wordpress --link blogs-mysql:mysql -e MY_SQL_ROOT_PASSWORD=root -p 8080:80 -d vmw-wordpress-img
