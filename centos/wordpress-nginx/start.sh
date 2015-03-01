#!/bin/bash

__check() {
	if [ -f ${WORDPRESS_ROOT}/wp-config.php ]; then
	  exit
	fi
}


__show_env() {
	# This is so the passwords show up in logs. 
	echo mysql root password: $MY_SQL_ROOT_PASSWORD
	echo wordpress password: $WORDPRESS_DB_PASSWORD
	echo MY_SQL_ROOT_PASSWORD: $MY_SQL_ROOT_PASSWORD
	echo MYSQL_PORT_3306_TCP_ADDR: $MYSQL_PORT_3306_TCP_ADDR
	echo MYSQL_PORT_3306_TCP_PORT: $MYSQL_PORT_3306_TCP_PORT
}

__set_perms() {
	chown root ${WORDPRESS_ROOT}/wp-config.php
	chmod 755 ${WORDPRESS_ROOT}/wp-config.php
}

__setup_wordpress_db() {
	mysql -uroot -p$MY_SQL_ROOT_PASSWORD -h$MYSQL_PORT_3306_TCP_ADDR -P$MYSQL_PORT_3306_TCP_PORT -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON $WORDPRESS_DB_USER_NAME.* TO '$WORDPRESS_DB_USER_NAME'@'localhost' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'; FLUSH PRIVILEGES;"
	sleep 10
}

__run_wordpress() {
	#supervisord -n
	. /etc/nginx/foreground.sh
}

# Call all functions
__check
__show_env
__set_perms
__setup_wordpress_db
__run_wordpress