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
	});
};    