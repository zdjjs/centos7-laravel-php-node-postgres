FROM zdjjs/centos7-git AS git

FROM centos:centos7
COPY --from=git /git /usr/local

ENV TZ=Asia/Tokyo \
NODE_VERSION=10 \
PHP_VERSION=72 \
POSTGRES_MAJOR=9 \
POSTGRES_MINOR=6 \
POSTGRES_REVISION=3 \
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/centos/.local/bin:/home/centos/bin:/home/centos/.composer/vendor/bin:/home/centos/.yarn/bin:/var/www/html/vendor/bin

RUN yum update -y \
&& yum install -y epel-release \
http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
https://download.postgresql.org/pub/repos/yum/${POSTGRES_MAJOR}.${POSTGRES_MINOR}/redhat/rhel-7-x86_64/pgdg-centos${POSTGRES_MAJOR}${POSTGRES_MINOR}-${POSTGRES_MAJOR}.${POSTGRES_MINOR}-${POSTGRES_REVISION}.noarch.rpm \
&& curl -sSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash - \
&& curl -sSL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo

RUN yum groups mark convert
RUN yum groupinstall -y base
RUN yum groupinstall -y core
RUN yum install -y --enablerepo=remi,remi-php${PHP_VERSION} php php-devel php-mbstring php-pdo php-pgsql php-gd php-xml php-mcrypt php-zip php-intl libzip-devel nodejs postgresql${POSTGRES_MAJOR}${POSTGRES_MINOR} yarn

RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

RUN useradd centos && echo 'centos ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER centos

RUN composer config -g repos.packagist composer https://packagist.jp && composer global require hirak/prestissimo && composer global require laravel/installer
RUN yarn global add vue-cli

WORKDIR /var/www/html
