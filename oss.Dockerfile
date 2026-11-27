# Upstream's Mautic image with the Amazon SES mailer plugin
# (etailors/mautic-amazon-ses): sends through the SES API and handles SNS
# bounce and complaint notifications at /mailer/callback. Adds the captcha
# plugin (firemultimedia/mautic-multi-captcha-bundle): Turnstile, hCaptcha and
# reCAPTCHA form fields checked on submit. Applies oss-patches/*.patch to
# Mautic's own code (see each patch) and adds the hourly segment email send
# to the cron jobs. Installs the PECL timezonedb extension, which replaces
# PHP's built-in time zone data for the CLI and Apache and loads before the
# other extensions. Removes node_modules:
# the built JavaScript and CSS are already in docroot/media, and only
# mautic:assets:generate reads node_modules.
ARG MAUTIC_VERSION
FROM mautic/mautic:${MAUTIC_VERSION}
ARG AMAZON_SES_PLUGIN_VERSION=1.0.45
ARG MULTI_CAPTCHA_PLUGIN_VERSION=1.0.9
ARG TIMEZONEDB_VERSION=2026.6
RUN pecl install "timezonedb-${TIMEZONEDB_VERSION}" \
 && docker-php-ext-enable --ini-name 0-timezonedb.ini timezonedb \
 && rm -rf /tmp/pear
WORKDIR /var/www/html
RUN COMPOSER_ALLOW_SUPERUSER=1 composer require --no-interaction --no-scripts --update-no-dev \
      "etailors/mautic-amazon-ses:${AMAZON_SES_PLUGIN_VERSION}" \
      "firemultimedia/mautic-multi-captcha-bundle:${MULTI_CAPTCHA_PLUGIN_VERSION}" \
 && rm -rf var/cache/* node_modules \
 && chown -R www-data:www-data docroot/plugins/AmazonSesBundle docroot/plugins/MauticMultiCaptchaBundle vendor
COPY oss-patches/ /tmp/oss-patches/
RUN for p in /tmp/oss-patches/*.patch; do patch -p1 --forward < "$p" || exit 1; done \
 && rm -rf /tmp/oss-patches var/cache/*
# Sends scheduled segment emails every hour.
RUN printf '\n# Segment emails - every hour at 30 past\n30 * * * * php /var/www/html/bin/console mautic:broadcasts:send 2>&1 | tee /tmp/stdout\n' >> /templates/mautic_cron
