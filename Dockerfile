FROM zdjjs/centos7-git AS git
FROM centos:centos7
COPY --from=git /git /usr/local

ENV NODE_VERSION=10 \
PHP_VERSION=72 \
POSTGRES_VERSION=9.6.3

RUN IFS='.' && read -ra PG_VERSION <<< "${POSTGRES_VERSION}" \
POSTGRES_MAJOR=${PG_VERSION[0]} \
POSTGRES_MINOR=${PG_VERSION[1]} \
POSTGRES_REVISION=${PG_VERSION[2]}

RUN yum update -y \
&& curl -sL https://rpm.nodesource.com/setup_10.x | bash - \
&& yum install -y epel-release \
http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
https://download.postgresql.org/pub/repos/yum/${POSTGRES_MAJOR}.${POSTGRES_MINOR}/redhat/rhel-7-x86_64/pgdg-centos${POSTGRES_MAJOR}${POSTGRES_MINOR}-${POSTGRES_MAJOR}.${POSTGRES_MINOR}-${POSTGRES_REVISION}.noarch.rpm \
&& yum install -y libzip-devel zip unzip wget nodejs postgresql96 \
&& yum install -y --enablerepo=remi,remi-php72 php php-devel php-mbstring php-pdo php-pgsql php-gd php-xml php-mcrypt php-zip \
&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/tmp \
&& mv /tmp/composer.phar /usr/local/bin/composer

RUN composer config -g repos.packagist composer https://packagist.jp \
&& composer global require hirak/prestissimo \
&& composer global require laravel/installer

