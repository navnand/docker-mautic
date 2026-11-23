# Upstream's Mautic image with the Amazon SES mailer plugin
# (etailors/mautic-amazon-ses): sends through the SES API and handles SNS
# bounce and complaint notifications at /mailer/callback.
ARG MAUTIC_VERSION
FROM mautic/mautic:${MAUTIC_VERSION}
ARG AMAZON_SES_PLUGIN_VERSION=1.0.45
WORKDIR /var/www/html
RUN COMPOSER_ALLOW_SUPERUSER=1 composer require --no-interaction --no-scripts --update-no-dev \
      "etailors/mautic-amazon-ses:${AMAZON_SES_PLUGIN_VERSION}" \
 && rm -rf var/cache/* \
 && chown -R www-data:www-data docroot/plugins/AmazonSesBundle vendor
