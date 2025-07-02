#!/usr/bin/env bash
set -eu -o pipefail
cd $APP_ROOT

# Create required composer.json and composer.lock files
composer create-project -n --no-install ${PROJECT:=localgovdrupal/localgov-project}
cp -r "${PROJECT#*/}"/* ./
rm -rf "${PROJECT#*/}" patches.lock.json

# Patch settings.php.
composer config scripts.post-drupal-scaffold-cmd \
    'cd web/sites/default && test -z "$(grep '\''include \$devpanel_settings;'\'' settings.php)" && patch -Np1 -r /dev/null < $APP_ROOT/.devpanel/drupal-settings.patch || :'
