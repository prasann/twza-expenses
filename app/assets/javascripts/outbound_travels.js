function populateTravelFields(){
	$.getJSON('/outbound_travels/data_to_suggest',function(data){
		var down_arrow_event = jQuery.Event("keydown");
		down_arrow_event.keyCode = 40;
		
		$('#outbound_travel_place').autocomplete({
			source: data.place, 
			minLength: 0
		});

		$('#outbound_travel_project').autocomplete({
			source: data.project, 
			minLength: 0
		});
		
		$('#outbound_travel_payroll_effect').autocomplete({
			source: data.payroll_effect, 
			minLength: 0
		}).focus(function(){            
            $(this).trigger(down_arrow_event);
        });
	});	
};    