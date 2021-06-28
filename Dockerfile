FROM arm64v8/php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Easy installation of PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Give permissions on installed Docker Installer
RUN chmod +x /usr/local/bin/install-php-extensions && sync

# Adds Driush Luncher
ADD https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar /usr/local/bin/drush

# Give permissions on installed Docker Installer
RUN chmod +x /usr/local/bin/drush && sync

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN install-php-extensions gd exif pcntl xdebug mbstring bcmath mysqli xml json opcache pdo_mysql

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
