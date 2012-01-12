function populateForexFields(){
	$.getJSON('/forex_payments/data_to_suggest',function(data){
		$('#forex_payment_place').autocomplete({
			source: data.place,
			minLength: 0
		});

		$('#forex_payment_vendor_name').autocomplete({
			source: data.vendor_name,
			minLength: 0
		});

		$('#forex_payment_currency').autocomplete({
			source: data.currency,
			minLength: 0
		});
	});
};    