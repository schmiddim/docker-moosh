FROM php:7.2-cli

MAINTAINER mail@itschmitt.com

LABEL vendor=IT\ Schmitt\
	org.hcpss.version="1.0.0" \
	org.hcpss.name="moosh"

# Install PHP extensions
RUN apt-get update && apt-get install -y \
		libmcrypt-dev \
		libicu-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libldap2-dev \
		libxml2-dev \
		--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install \
		intl ldap  mysqli gd iconv zip simplexml xml json tokenizer \
		intl xmlrpc soap opcache
RUN pecl install mcrypt-1.0.2 
RUN docker-php-ext-enable mcrypt

COPY install-composer.sh /install-composer.sh

RUN apt-get update && apt-get install -y git wget \
	&& /bin/sh /install-composer.sh \
	&& mv /composer.phar /usr/local/bin/composer \
	&& git clone git://github.com/tmuras/moosh.git \
	&& sed -ir s@\"corneltek/getoptionkit\":\".*\",@\"corneltek/getoptionkit\":\"2\.5\.0\",@ /moosh/composer.json \
	&& composer update -d /moosh \
	&& ln -s /moosh/moosh.php /usr/local/bin/moosh

CMD ["moosh"]
