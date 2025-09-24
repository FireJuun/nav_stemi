#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects
# initial spec: https://codewithandrea.com/articles/flutter-firebase-multiple-flavors-flutterfire-cli/

set -e # exit immediately if a command exits with a non-zero status. 

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'dev', 'stg', or 'prod'."
  exit 1
fi

ENV=$1
FLAVOR=""
PROJECT=""
OUT_FILE=""
IOS_BUNDLE_ID=""
IOS_OUT=""
ANDROID_PACKAGE_NAME=""
ANDROID_OUT=""

case $ENV in
  dev)
    # [dev]: ************* CHANGE THESE SETTINGS *************
    PROJECT="nav-stemi" # your firebase_project_ID
    IOS_BUNDLE_ID="com.firejuun.nav-stemi.dev" # ios_app_ID
    ANDROID_PACKAGE_NAME="com.firejuun.navstemi.dev" # android_app_ID
    # ********************************************************

    # []: constant for dev
    FLAVOR="development"
    OUT_FILE="lib/firebase_options_dev.dart"
    IOS_OUT="ios/flavors/development/GoogleService-Info.plist"
    ANDROID_OUT="android/app/src/development/google-services.json"
    ;;

  stg)
    # [stage]: ************* CHANGE THESE SETTINGS *************
    PROJECT="nav-stemi-stg"  # your firebase_project_ID
    IOS_BUNDLE_ID="com.firejuun.nav-stemi.stg" # ios_app_ID
    ANDROID_PACKAGE_NAME="com.firejuun.navstemi.stg" # android_app_ID
    # ********************************************************
    
    # []: constant for stage
    FLAVOR="staging"
    OUT_FILE="lib/firebase_options_stg.dart"
    IOS_OUT="ios/flavors/staging/GoogleService-Info.plist"
    ANDROID_OUT="android/app/src/staging/google-services.json"
    ;;

  prod)
    # [prod]: ************* CHANGE THESE SETTINGS *************
    PROJECT="nav-stemi-prod" # [prod] firebase_project_ID
    IOS_BUNDLE_ID="com.firejuun.nav-stemi.prod" # [prod] ios_app_ID
    ANDROID_PACKAGE_NAME="com.firejuun.nav-stemi.prod" # [prod]
    # ************************************************** android_app_ID******

    # []: constant for prod
    FLAVOR="production"
    OUT_FILE="lib/firebase_options_prod.dart"
    IOS_OUT="ios/flavors/production/GoogleService-Info.plist"
    ANDROID_OUT="android/app/src/production/google-services.json"
    ;;

  *)
    echo "Error: Invalid environment specified. Use 'dev', 'stg', or 'prod'."
    exit 1
    ;;
esac

# For prod, we just print the commands that would be run
# This is so we can be very, very intentional about when to
# implement or update new connections to a production environment
if [[ "$ENV" == "prod" ]]; then
  echo "# Prod environment configuration is commented out by default."
  echo "# To enable, comment the `CMD_PREFIX=` line below and run the script again."
  ### *********** Comment below for prod to work ***********
  CMD_PREFIX="# "
  # ************************************************** 
fi

# Delete existing file to ensure a fresh generation
if [[ -f "$OUT_FILE" ]]; then
  echo "Removing existing file: $OUT_FILE"
  rm "$OUT_FILE"
fi

# Common command arguments
BASE_CMD="flutterfire config -y --project=$PROJECT --out=$OUT_FILE --ios-bundle-id=$IOS_BUNDLE_ID --ios-out=$IOS_OUT"

# iOS build configs
IOS_BUILD_CONFIGS=("Debug" "Profile" "Release")

for config in "${IOS_BUILD_CONFIGS[@]}"; do
  ios_build_config_name="$config-$FLAVOR"
  
  platforms="ios"
  android_args=""
  if [[ "$config" == "Release" ]]; then
    platforms="android,ios"
    android_args="--android-package-name=$ANDROID_PACKAGE_NAME --android-out=$ANDROID_OUT"
  fi
  
  full_cmd="$BASE_CMD --platforms=\"$platforms\" --ios-build-config=$ios_build_config_name $android_args"
  
  echo -e "\n**************** START CONFIG *******************"
  echo "${CMD_PREFIX}${full_cmd}"
  if [[ "$ENV" != "prod" ]]; then
    eval "${full_cmd}"
  fi
  echo -e "**************** END CONFIG *******************\n"
done

echo "Firebase configuration for $ENV environment has been generated/updated."

# Create placeholder files for other environments to avoid build errors
PLACEHOLDER_CONTENT="// Temporary file to avoid Flutter run errors
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnimplementedError();
  }
}"

FIREBASE_OPTIONS_FILES=(
  "lib/firebase_options_dev.dart"
  "lib/firebase_options_stg.dart"
  "lib/firebase_options_prod.dart"
)

for file in "${FIREBASE_OPTIONS_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e "\n**************** PLACEHOLDERS *******************"
    echo "Creating placeholder file for $file"
    echo -e "$PLACEHOLDER_CONTENT" > "$file"
  fi
done

echo -e "Placeholder check complete.\n"