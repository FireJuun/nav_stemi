#!/bin/sh

# spec: https://medium.com/@nayanbabariya/set-up-environment-variables-in-flutter-for-secure-and-scalable-apps-7409ae0c383e
# Specify the file path to write Dart define.
# Here we will create a file named `Dart-Defines.xcconfig`.
OUTPUT_FILE="${SRCROOT}/Flutter/Dart-Defines.xcconfig"
# Empty the file first so that no old properties remain when changing the contents of the Dart define.
: > $OUTPUT_FILE

# Decode Dart define with this function.
function decode_url() { echo "${*}" | base64 --decode; }

IFS=',' read -r -a define_items <<<"$DART_DEFINES"

for index in "${!define_items[@]}"
do
    item=$(decode_url "${define_items[$index]}")
    # Dart definition also includes items automatically defined on the Flutter side.
    # However, if you write out those definitions, you will not be able to build due to an error, so
    # Items starting with flutter or FLUTTER are not output.
    lowercase_item=$(echo "$item" | tr '[:upper:]' '[:lower:]')
    if [[ $lowercase_item != flutter* ]]; then
        echo "$item" >> "$OUTPUT_FILE"
    fi
done