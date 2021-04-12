// Manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'

Spree.ready(function($) {
  var radios = $('#product-variants-sellers input[type="radio"]');

  if (radios.length > 0) {
    var selectedRadio = $(
      '#product-variants-sellers input[type="radio"][checked="checked"]'
    );
    if (!selectedRadio.length) {
      selectedRadio = radios;
      $(selectedRadio[0]).prop('checked', true);
    }
    const variantId = selectedRadio[0].value.split(" ")[0];
    Spree.showVariantImages(variantId);
    Spree.updateVariantPrice(selectedRadio);
  }

  Spree.addImageHandlers();

  radios.click(function(event) {
    const variantId = this.value.split(" ")[0]
    Spree.showVariantImages(variantId);
    Spree.updateVariantPrice($(this));
  });
})
