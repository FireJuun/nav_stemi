#!/bin/sh

#  copy_google_service_info.sh
#  Runner
#
#  This script copies the correct GoogleService-Info.plist for the selected build flavor.
#

# Get the flavor from the build configuration (e.g., "Debug-development" -> "development")
FLAVOR=$(echo "${CONFIGURATION}" | sed 's/.*-//')

# Path to the source GoogleService-Info.plist
SOURCE_PLIST="${SRCROOT}/flavors/${FLAVOR}/GoogleService-Info.plist"

# Path to the destination GoogleService-Info.plist
DESTINATION_PLIST="${SRCROOT}/Runner/GoogleService-Info.plist"

# Check if the source file exists and copy it
if [ -f "$SOURCE_PLIST" ]; then
    echo "Copying $SOURCE_PLIST to $DESTINATION_PLIST"
    cp "$SOURCE_PLIST" "$DESTINATION_PLIST"
else
    echo "Warning: GoogleService-Info.plist not found for flavor ${FLAVOR} at ${SOURCE_PLIST}"
fi
