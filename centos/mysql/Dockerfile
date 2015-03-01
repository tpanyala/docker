FROM artfact-repo.vmware.com/vmware/vcos66base
MAINTAINER Thirupati Panyala <thirup@vmware.com>

##### ******************** #######
# FUTURE TODOs
#  - Add a volume container
#  - Add a backup container for the volume above
#  - Add scripts to identify if the database already exists and if it does, do not run initialization steps for root passwd, etc
#  - Add custom configuations file through my.cnf
#  - Make sure to remove the source files from the image after installation and post-installation steps are done
#  - Add Entrypoint file
#  - Make sure MySQL can run in cluster (master/slave) mode
##### ******************** #######



# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

ENV MYSQL_RELEASEVER 5.6
ENV MYSQL_ROOT_PASSWORD root
ENV DATADIR data

# RUN mkdir "${MYSQL_INSTALL_ROOT}"

RUN yum --quiet --assumeyes install mysql-server

ADD secureMySQL.sh /secureMySQL.sh
ADD start.sh /start.sh
RUN chmod 755 /start.sh
RUN chmod 755 /secureMySQL.sh
RUN /secureMySQL.sh




VOLUME /var/lib/mysql

#RUN chown -R mysql:mysql "$DATADIR"

EXPOSE 3306
CMD ["/usr/bin/mysqld_safe"]
#CMD ["/bin/bash", "/start.sh"]
