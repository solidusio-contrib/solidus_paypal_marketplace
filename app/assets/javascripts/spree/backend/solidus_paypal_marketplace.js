// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'

Spree.ready(function () {
  'use strict';

  if ($('#price_variant_id').length > 0) {
    $('#price_variant_id').variantAutocomplete();
  }
});
