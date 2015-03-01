sudo docker run --name blogs-mysql -e MY_SQL_ROOT_PASSWORD=root -p 3306:3306 -d  artfact-repo.vmware.com/vmware/mysql

sudo docker run --name blogs-wordpress --link blogs-mysql:mysql -e MY_SQL_ROOT_PASSWORD=root -p 8080:80 -d  artfact-repo.vmware.com/vmware/wordpress
