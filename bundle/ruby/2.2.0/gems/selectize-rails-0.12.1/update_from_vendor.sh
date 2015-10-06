#!/bin/bash

# Checkout vendor repo
echo "Cloning brianreavis/selectize.js github repo into tmp_vendor"
git clone https://github.com/brianreavis/selectize.js.git tmp_vendor

# Copy files
echo "Copying selectize.js"
cp tmp_vendor/dist/js/standalone/selectize.js vendor/assets/javascripts/selectize.js
echo "Copying css files"
cp tmp_vendor/dist/css/*.css vendor/assets/stylesheets/

# Delete vendor repo
echo "Removing cloned vendor repo"
rm -rf tmp_vendor

echo "Finished... You'll need to commit the changes. You should consider updating the changelog and gem version number"
