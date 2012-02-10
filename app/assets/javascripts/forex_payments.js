function populateForexFields(){
  $.getJSON('/forex_payments/data_to_suggest',function(data){
    var down_arrow_event = jQuery.Event("keydown");
    down_arrow_event.keyCode = 40;

    $('#forex_payment_place').autocomplete({
      source: data.place,
      minLength: 0
    });

    $('#forex_payment_vendor_name').autocomplete({
      source: data.vendor_name,
      minLength: 0
    }).focus(function(){
      $(this).trigger(down_arrow_event);
    });

    $('#forex_payment_currency').autocomplete({
      source: data.currency,
      minLength: 0
    }).focus(function(){
      $(this).trigger(down_arrow_event);
    });

    $('#forex_payment_office').autocomplete({
      source: data.office,
      minLength: 0
    }).focus(function(){
      $(this).trigger(down_arrow_event);
    });

    $(':input[type=submit]').click(function(event){
      credit_card_number = $('.credit_card_number') ? $('.credit_card_number').val() : '';
      if (credit_card_number != '' && (!isValidCreditCardNumber(credit_card_number) || !isExpiryDateSpecified())) {
        event.preventDefault();
        return false;
      }
    })

    $('.credit_card_expiry').datepicker("destroy").datepicker({dateFormat : "m/yy"});
  });
};
function isValidCreditCardNumber(credit_card_number) {
  if (!/^\d{16}[^\d]+$/.test(credit_card_number.replace(/\s/g, ''))) {
    alert('Please enter a valid 16-digit credit-card number');
    return false;
  }
  return true;
}

function isExpiryDateSpecified() {
  if ((credit_card_expiry = $('.credit_card_expiry')) && credit_card_expiry.val() == '') {
    alert('Please specify the expiry date for the entered credit card number')
    return false;
  }
  return true;
}

