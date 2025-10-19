#!/bin/bash

set -e # exit on first failed command
set -x # print all executed commands to the log

echo ""
echo "Setting up environment..."

dart pub global activate flutterfire_cli

echo ""
echo "Configuring Firebase..."

flutterfire configure --project=nav-stemi flutterfire configure --platforms=android,ios,macos,web,linux,windows --yes