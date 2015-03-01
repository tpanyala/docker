FROM artfact-repo.vmware.com/vmware/vcos66base

MAINTAINER Thirupati Panyala <thirup@vmware.com>

# @TODO: Add user webdev:webdev and have the ownership to /var/www /data/wp
#RUN useradd -ms /bin/bash webdev

# Source/install files directory
ENV SRC_FOLDER /src

# Root folder for Wordpress
ENV WORDPRESS_ROOT /data/wp

# Wordpress version
ENV WORDPRESS_VERSION 4.1.1
ENV WORDPRESS_UPSTREAM_VERSION 4.1.1
ENV WORDPRESS_SHA1 15d38fe6c73121a20e63ccd8070153b89b2de6a9


#Use the wordpress user name for the database schema name as well
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASSWORD wordpress
ENV MY_SQL_ROOT_PASSWORD root

#Optionally, setup the keys and salts for wordpress
#ENV WORDPRESS_AUTH_KEY
#ENV WORDPRESS_SECURE_AUTH_KEY
#ENV WORDPRESS_LOGGED_IN_KEY
#ENV WORDPRESS_NONCE_KEY
#ENV WORDPRESS_AUTH_SALT
#ENV WORDPRESS_SECURE_AUTH_SALT
#ENV WORDPRESS_LOGGED_IN_SALT
#ENV WORDPRESS_NONCE_SALT

# Create the necessary folders
RUN mkdir -p ${SRC_FOLDER}
RUN mkdir -p ${WORDPRESS_ROOT}

#########################################################
#DEPLOY THE WORDPRESS

# upstream tarballs include ./wordpress/ so this gives us /src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C ${SRC_FOLDER} \
	&& rm wordpress.tar.gz
	
RUN chown -R root ${SRC_FOLDER}
RUN chmod -R 755 ${SRC_FOLDER}

RUN cp -R ${SRC_FOLDER}/wordpress/* ${WORDPRESS_ROOT}

# Remove the source once done
RUN rm -rf ${SRC_FOLDER}

#########################################################

VOLUME ${WORDPRESS_ROOT}

# This custom repo file just activate "centos-plus" repo otherwise you will
# get error with selinux dependencies
ADD ./nginx-repo/nginx.repo /etc/yum.repos.d/nginx.repo

# Update the base system with latest patches
RUN yum -y update && yum clean all

# Prepare the ground to use software collections
RUN yum -y install scl-utils && yum clean all

# Install nginx
RUN yum -y install nginx php php-fpm php-mysql php-gd mysql && yum clean all

# Configure nginx
ADD ./nginx-conf/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx-conf/wordpress/virtual.conf /etc/nginx/wordpress/virtual.conf
ADD ./foreground.sh /etc/nginx/foreground.sh
ADD ./start.sh /start.sh
ADD ./entrypoint.sh /entrypoint.sh

# Configure FPM
ADD php-conf/www.conf /etc/php-fpm.d/www.conf

# Configure Wordpress - instead of copying the whole wp-config.php, configure each param fore repeatability
#ADD ./wordpress-config/wp-config.php ${WORDPRESS_ROOT}/wp-config.php

# Deploy the test file
ADD ./nginx-web/index.php /data/wp/info.php

#Ensure nginx comes up when the machine restarts
RUN chkconfig --add php-fpm & chkconfig --levels 235 php-fpm on
RUN chkconfig --add nginx & chkconfig --levels 235 nginx on

WORKDIR /data/wp

#nginx port
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "/etc/nginx/foreground.sh"]