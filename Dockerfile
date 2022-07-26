FROM bitnami/php-fpm:7.4.30-debian-11-r12

# 安装编译软件
RUN apt update && \
	apt install -y autoconf && \
	apt install -y build-essential && \
	apt install -y libyaml-dev && \
	apt install -y librdkafka-dev && \
	apt install -y zlib1g-dev && \
	apt install -y git

# 编译安装protobuf 非必要不要添加, 体积直线上升3G
RUN cd /app && \
	wget https://github.com/protocolbuffers/protobuf/releases/download/v21.2/protobuf-all-21.2.tar.gz -O protobuf-all-21.2.tar.gz && \
	tar -zxvf protobuf-all-21.2.tar.gz && rm protobuf-all-21.2.tar.gz && \
	cd protobuf-21.2 && ./configure -prefix=/usr/local/protobuf && make && make install

# 安装扩展包
RUN cd /app && \
	wget https://pecl.php.net/get/swoole-4.8.10.tgz -O swoole-4.8.10.tgz && \
	tar -zxvf swoole-4.8.10.tgz && rm package.xml swoole-4.8.10.tgz && \
	cd swoole-4.8.10 && phpize && \
	./configure --prefix=/opt/bitnami/php --with-php-config=/opt/bitnami/php/bin/php-config && \
	make && make install && \
	echo '[swoole]' >> /opt/bitnami/php/etc/conf.d/swoole.ini && \
	echo 'extension=swoole' >> /opt/bitnami/php/etc/conf.d/swoole.ini && \
	echo 'swoole.use_shortname=Off' >> /opt/bitnami/php/etc/conf.d/swoole.ini && \
	cd /app && \
	wget https://pecl.php.net/get/redis-5.3.7.tgz -O redis-5.3.7.tgz && \
	tar -zxvf redis-5.3.7.tgz && rm package.xml redis-5.3.7.tgz && \
	cd redis-5.3.7 && phpize && \
	./configure --prefix=/opt/bitnami/php --with-php-config=/opt/bitnami/php/bin/php-config && \
	make && make install && \
	echo '[redis]' >> /opt/bitnami/php/etc/conf.d/redis.ini && \
	echo 'extension=redis' >> /opt/bitnami/php/etc/conf.d/redis.ini && \
	cd /app && \
	wget https://pecl.php.net/get/yaml-2.2.2.tgz -O yaml-2.2.2.tgz && \
	tar -zxvf yaml-2.2.2.tgz && rm package.xml yaml-2.2.2.tgz && \
	cd yaml-2.2.2 && phpize && \
	./configure --prefix=/opt/bitnami/php --with-php-config=/opt/bitnami/php/bin/php-config && \
	make && make install && \
	echo '[yaml]' >> /opt/bitnami/php/etc/conf.d/yaml.ini && \
	echo 'extension=yaml' >> /opt/bitnami/php/etc/conf.d/yaml.ini && \
	cd /app && \
	wget https://pecl.php.net/get/rdkafka-6.0.3.tgz -O rdkafka-6.0.3.tgz && \
	tar -zxvf rdkafka-6.0.3.tgz && rm package.xml rdkafka-6.0.3.tgz && \
	cd rdkafka-6.0.3 && phpize && \
	./configure --prefix=/opt/bitnami/php --with-php-config=/opt/bitnami/php/bin/php-config && \
	make && make install && \
	echo '[rdkafka]' >> /opt/bitnami/php/etc/conf.d/rdkafka.ini && \
	echo 'extension=rdkafka' >> /opt/bitnami/php/etc/conf.d/rdkafka.ini && \
	cd /app && \
	wget https://pecl.php.net/get/grpc-1.47.0.tgz -O grpc-1.47.0.tgz && \
	tar -zxvf grpc-1.47.0.tgz && rm package.xml grpc-1.47.0.tgz && \
	cd grpc-1.47.0 && phpize && \
	./configure --prefix=/opt/bitnami/php --with-php-config=/opt/bitnami/php/bin/php-config && \
	make && make install && \
	echo '[grpc]' >> /opt/bitnami/php/etc/conf.d/grpc.ini && \
	echo 'extension=grpc' >> /opt/bitnami/php/etc/conf.d/grpc.ini && \
	echo "grpc.enable_fork_support = 1" >> /opt/bitnami/php/etc/conf.d/grpc.ini && \
	cd /app && \
	wget https://pecl.php.net/get/protobuf-3.21.2.tgz -O protobuf-3.21.2.tgz && \
	tar -zxvf protobuf-3.21.2.tgz && rm package.xml protobuf-3.21.2.tgz && \
	cd protobuf-3.21.2 && phpize && \
	./configure --prefix=/opt/bitnami/php --with-php-config=/opt/bitnami/php/bin/php-config && \
	make && make install && \
	echo '[protobuf]' >> /opt/bitnami/php/etc/conf.d/protobuf.ini && \
	echo 'extension=protobuf' >> /opt/bitnami/php/etc/conf.d/protobuf.ini

# 删除软件包
RUN cd /app && \
	rm -rf swoole-4.8.10 redis-5.3.7 yaml-2.2.2 rdkafka-6.0.3 grpc-1.47.0 protobuf-3.21.2 protobuf-21.2


# 开启已有扩展
RUN sed -i 's/^\;extension\=pdo\_pgsql/extension\=pdo\_pgsql/g' /opt/bitnami/php/etc/php.ini && \
	sed -i 's/^\;extension\ \=\ imagick/extension\ \=\ imagick/g' /opt/bitnami/php/lib/php.ini && \
	sed -i 's/^\;extension\ \=\ mcrypt/extension\ \=\ mcrypt/g' /opt/bitnami/php/lib/php.ini && \
	sed -i 's/^\;extension\ \=\ memcached/extension\ \=\ memcached/g' /opt/bitnami/php/lib/php.ini && \
	sed -i 's/^\;extension\ \=\ mongodb/extension\ \=\ mongodb/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;\[XDebug\]/\[XDebug\]/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;zend\_extension\ \=\ xdebug/zend\_extension\ \=\ xdebug/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;xdebug\.mode\ \=\ debug/xdebug\.mode\ \=\ debug/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;xdebug\.client_host\ \=\ 127\.0\.0\.1/xdebug\.client_host\ \=\ 127\.0\.0\.1/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;xdebug\.client_port\ \=\ 9000/xdebug\.client_port\ \=\ 9003/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;xdebug\.output_dir\ \=\ \/tmp/xdebug\.output_dir\ \=\ \/tmp/g' /opt/bitnami/php/lib/php.ini && \
	# sed -i 's/^\;xdebug\.remote_handler\ \=\ dbgp/xdebug\.remote_handler\ \=\ dbgp/g' /opt/bitnami/php/lib/php.ini && \
	sed -i 's/^pm\ \=\ ondemand/pm\ \=\ static/g' /opt/bitnami/php/etc/php-fpm.d/www.conf && \
	sed -i 's/^pm\.max\_children\ \=\ 5/pm\.max\_children\ \=\ 100/g' /opt/bitnami/php/etc/php-fpm.d/www.conf

# composer 安装并删除 更换镜像 设置github token
RUN cd /app && \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php && \
	php -r "unlink('composer-setup.php');" && \
	mv composer.phar /usr/local/bin/composer && \
	composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \
	composer config -g github-oauth.github.com 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

ENV PATH="/usr/local/protobuf/bin:$PATH" \
	LD_LIBRARY_PATH="/usr/local/protobuf/lib"

EXPOSE 80 8000 9000 9003

WORKDIR /app

CMD ["php-fpm", "-F", "--pid", "/opt/bitnami/php/tmp/php-fpm.pid", "-y", "/opt/bitnami/php/etc/php-fpm.conf"]