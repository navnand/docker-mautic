# Upstream's Mautic image with the Amazon SES mailer plugin
# (etailors/mautic-amazon-ses): sends through the SES API and handles SNS
# bounce and complaint notifications at /mailer/callback. Adds the captcha
# plugin (firemultimedia/mautic-multi-captcha-bundle): Turnstile, hCaptcha and
# reCAPTCHA form fields checked on submit. Removes node_modules:
# the built JavaScript and CSS are already in docroot/media, and only
# mautic:assets:generate reads node_modules.
ARG MAUTIC_VERSION
FROM mautic/mautic:${MAUTIC_VERSION}
ARG AMAZON_SES_PLUGIN_VERSION=1.0.45
ARG MULTI_CAPTCHA_PLUGIN_VERSION=1.0.9
WORKDIR /var/www/html
RUN COMPOSER_ALLOW_SUPERUSER=1 composer require --no-interaction --no-scripts --update-no-dev \
      "etailors/mautic-amazon-ses:${AMAZON_SES_PLUGIN_VERSION}" \
      "firemultimedia/mautic-multi-captcha-bundle:${MULTI_CAPTCHA_PLUGIN_VERSION}" \
 && rm -rf var/cache/* node_modules \
 && chown -R www-data:www-data docroot/plugins/AmazonSesBundle docroot/plugins/MauticMultiCaptchaBundle vendor
