# Use uma imagem base PHP com Nginx
FROM php:8.2-fpm-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    icu-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd intl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar Nginx
COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf

# Definir o diretório de trabalho
WORKDIR /var/www/html

# Copiar o código da aplicação
COPY . .

# Instalar dependências do Laravel
RUN composer install --no-dev --optimize-autoloader

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Gerar a chave da aplicação
RUN php artisan key:generate

# Expor a porta 80
EXPOSE 80

# Comando de inicialização (roda Nginx e PHP-FPM)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
