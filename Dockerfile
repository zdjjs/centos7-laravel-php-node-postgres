FROM zdjjs/centos7-git AS git

FROM centos:centos7
COPY --from=git /git /usr/local

ENV TZ=Asia/Tokyo \
NODE_VERSION=10 \
PHP_VERSION=72 \
POSTGRES_VERSION=9.6.3

RUN IFS='.' && read -ra PG_VERSION <<< "${POSTGRES_VERSION}" \
POSTGRES_MAJOR=${PG_VERSION[0]} \
POSTGRES_MINOR=${PG_VERSION[1]} \
POSTGRES_REVISION=${PG_VERSION[2]}

RUN yum update -y \
&& yum install -y epel-release \
http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
https://download.postgresql.org/pub/repos/yum/${POSTGRES_MAJOR}.${POSTGRES_MINOR}/redhat/rhel-7-x86_64/pgdg-centos${POSTGRES_MAJOR}${POSTGRES_MINOR}-${POSTGRES_MAJOR}.${POSTGRES_MINOR}-${POSTGRES_REVISION}.noarch.rpm

RUN yum groupinstall -y base

RUN curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash -

RUN yum install -y --enablerepo=remi,remi-php${PHP_VERSION} php php-devel php-mbstring php-pdo php-pgsql php-gd php-xml php-mcrypt php-zip php-intl libzip-devel nodejs postgresql${POSTGRES_MAJOR}${POSTGRES_MINOR}

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

RUN useradd centos && echo 'centos ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER centos

RUN composer config -g repos.packagist composer https://packagist.jp && composer global require hirak/prestissimo
RUN composer global require laravel/installer

WORKDIR /var/www/html
