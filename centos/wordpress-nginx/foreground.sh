#!/bin/bash

read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

# Start the php-fpm and then start nginx
service php-fpm start
/usr/sbin/nginx -c /etc/nginx/nginx.conf