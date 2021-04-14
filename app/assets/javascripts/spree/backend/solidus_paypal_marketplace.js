// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'

Spree.ready(function () {
  'use strict';
  let $variantSelect = $('#price_variant_id')
  if ($variantSelect.length > 0) {
    let $priceAmount = $('#price_amount');
    $variantSelect.variantAutocomplete({ for_seller: true });
    $variantSelect.on("change", function (event) {
      console.log(event.added.price)
      if (event.added.price != null) {
        $priceAmount.val(event.added.price);
      }
    });
  }
});
