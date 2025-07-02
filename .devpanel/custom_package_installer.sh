#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Copyright (C) 2024 DevPanel
# You can install any service here to support your project
# Please make sure you run apt update before install any packages
# Example:
# - sudo apt-get update
# - sudo apt-get install nano
#
# ----------------------------------------------------------------------

sudo apt-get update
sudo apt-get install -y nano

# Install VSCode Extensions
if [[ -n "$DP_VSCODE_EXTENSIONS" ]]; then
    sudo chown -R www:www $APP_ROOT/.vscode/extensions/
    IFS=','
    for value in $DP_VSCODE_EXTENSIONS; do
        code-server --install-extension $value --user-data-dir=$APP_ROOT/.vscode
    done
fi

PECL_UPDATED=false
# Install APCU extension. Bypass question about enabling internal debugging.
if ! php --re apcu > /dev/null 2>&1; then
  $PECL_UPDATED || sudo pecl update-channels && PECL_UPDATED=true
  sudo pecl install apcu <<< ''
  echo 'extension=apcu.so' | sudo tee /usr/local/etc/php/conf.d/apcu.ini
fi
# Install uploadprogress extension.
if ! php --re uploadprogress > /dev/null 2>&1; then
  $PECL_UPDATED || sudo pecl update-channels && PECL_UPDATED=true
  sudo pecl install uploadprogress
  echo 'extension=uploadprogress.so' | sudo tee /usr/local/etc/php/conf.d/uploadprogress.ini
fi
# Reload Apache if it's running.
if $PECL_UPDATED && sudo /etc/init.d/apache2 status > /dev/null; then
  sudo /etc/init.d/apache2 reload
fi
