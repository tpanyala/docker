#!/bin/bash
set -e

# Check if wordpress is installed? If not, exit
__check_wordpress_installation(){
	if ! [ -e index.php -a -e wp-includes/version.php ]; then
		echo >&2 "WordPress not found in $(pwd) - exiting now..."
		exit 1
	fi
}

# setup DB parameters for both My SQL for initial wordpress database creation
# as well as wordpress username, password etc for wordpress to connect at runtime
__setup_mysql_wordpress_db_params(){
	if [ -n "$MYSQL_PORT_3306_TCP" ]; then
		if [ -z "$WORDPRESS_DB_HOST" ]; then
			WORDPRESS_DB_HOST=${MYSQL_PORT_3306_TCP_ADDR}:${MYSQL_PORT_3306_TCP_PORT}
		else
			echo >&2 'warning: both WORDPRESS_DB_HOST and MYSQL_PORT_3306_TCP found'
			echo >&2 "  Connecting to WORDPRESS_DB_HOST ($WORDPRESS_DB_HOST)"
			echo >&2 '  instead of the linked mysql container'
		fi
	
	fi

	if [ -z "$WORDPRESS_DB_HOST" ]; then
		echo >&2 'error: missing WORDPRESS_DB_HOST and MYSQL_PORT_3306_TCP environment variables'
		echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
		echo >&2 '  with -e WORDPRESS_DB_HOST=hostname:port?'
		exit 1
	fi

	# if we're linked to MySQL, and we're using the root user, and our linked
	# container has a default "root" password set up and passed through... :)
	: ${WORDPRESS_DB_USER:=root}
	if [ "$WORDPRESS_DB_USER" = 'root' ]; then
		: ${WORDPRESS_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
	fi
	: ${WORDPRESS_DB_NAME:=wordpress}

	if [ -z "$WORDPRESS_DB_PASSWORD" ]; then
		echo >&2 'error: missing required WORDPRESS_DB_PASSWORD environment variable'
		echo >&2 '  Did you forget to -e WORDPRESS_DB_PASSWORD=... ?'
		echo >&2
		echo >&2 '  (Also of interest might be WORDPRESS_DB_USER and WORDPRESS_DB_NAME.)'
		exit 1
	fi
}

__check_wordpress_config(){
	if [ -f $WORDPRESS_ROOT/wp-config.php ]; then
	  exit
	fi
}

# update both the database and auth & salt keys in wp-config.php
__setup_db_auth_salt_keys(){

	sed -e "s/database_name_here/$WORDPRESS_DB_NAME/
	
	s/database_name_here/$WORDPRESS_DB_USER/
	s/username_here/$WORDPRESS_DB_USER/
	s/password_here/$WORDPRESS_DB_PASSWORD/
	s/localhost/$WORDPRESS_DB_HOST/
	
	/'AUTH_KEY'/s/put your unique phrase here/`$WORDPRESS_AUTH_KEY`/
	/'SECURE_AUTH_KEY'/s/put your unique phrase here/`$WORDPRESS_SECURE_AUTH_KEY`/
	/'LOGGED_IN_KEY'/s/put your unique phrase here/`$WORDPRESS_LOGGED_IN_KEY`/
	/'NONCE_KEY'/s/put your unique phrase here/`$WORDPRESS_NONCE_KEY`/
	/'AUTH_SALT'/s/put your unique phrase here/`$WORDPRESS_AUTH_SALT`/
	/'SECURE_AUTH_SALT'/s/put your unique phrase here/`$WORDPRESS_SECURE_AUTH_SALT`/
	/'LOGGED_IN_SALT'/s/put your unique phrase here/`$WORDPRESS_LOGGED_IN_SALT`/
	/'NONCE_SALT'/s/put your unique phrase here/`$WORDPRESS_NONCE_SALT`/" $WORDPRESS_ROOT/wp-config-sample.php > $WORDPRESS_ROOT/wp-config.php
}

# Create the wordpress database initially only if it doesn't exit already
__create_wordpress_db(){
	mysql -uroot -p$MY_SQL_ROOT_PASSWORD -h$MYSQL_PORT_3306_TCP_ADDR -P$MYSQL_PORT_3306_TCP_PORT -e "CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME; GRANT ALL PRIVILEGES ON $WORDPRESS_DB_USER.* TO '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'; FLUSH PRIVILEGES;"
}

# Call the functions
__check_wordpress_installation
__setup_mysql_wordpress_db_params
__check_wordpress_config
__setup_db_auth_salt_keys
__create_wordpress_db

exec "$@"