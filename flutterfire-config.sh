#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects
# spec: https://codewithandrea.com/articles/flutter-firebase-multiple-flavors-flutterfire-cli/

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'dev', 'stg', or 'prod'."
  exit 1
fi

case $1 in
  dev)
    flutterfire config \
      --project=nav-stemi \
      --out=lib/firebase_options_dev.dart \
      --ios-bundle-id=com.firejuun.nav-stemi.dev \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --android-package-name=com.firejuun.navstemi.dev \
      --android-out=android/app/src/dev/google-services.json
    ;;
  stg)
    flutterfire config \
      --project=nav-stemi-stg \
      --out=lib/firebase_options_stg.dart \
      --ios-bundle-id=com.firejuun.nav-stemi.stg \
      --ios-out=ios/flavors/stg/GoogleService-Info.plist \
      --android-package-name=com.firejuun.navstemi.stg \
      --android-out=android/app/src/stg/google-services.json
    ;;
  prod)
    # Do nothing
    # Currently unset
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev', 'stg', or 'prod'."
    exit 1
    ;;
esac