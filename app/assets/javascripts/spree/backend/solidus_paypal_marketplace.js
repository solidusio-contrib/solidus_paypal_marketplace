// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'

Spree.ready(function () {
  'use strict';
  let $variantSelect = $('#price_variant_id')
  if ($variantSelect.length > 0) {
    let $amount = $('#price_amount');
    let $sellerStockAvailability = $('#price_seller_stock_availability');
    $variantSelect.variantAutocomplete({ for_seller: true });
    $variantSelect.on("change", function (event) {
      console.log(event.added.price)
      if (event.added.price != null) {
        $amount.val(event.added.price);
        $sellerStockAvailability.val(event.added.current_seller_on_hand)
      }
    });
  }
});
