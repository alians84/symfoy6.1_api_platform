FROM php:8.1-fpm-alpine

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk update && apk add --no-cache \
   libjpeg-turbo-dev \
   libpng-dev \
   libwebp-dev \
   freetype-dev \
   libzip-dev \
   acl \
   fcgi \
   file \
   gettext \
   git \
   zip \
    ;

# Clear cache
RUN apk del && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl

#RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype

RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN addgroup -g 1000 www
RUN adduser -D -g '' newuser
# Copy existing application directory contents
COPY  . /var/www

# Copy existing application directory permissions
COPY --chown=newuser:www . /var/www
# Change current user to www
USER newuser

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
