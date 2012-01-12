function populateTravelFields(){
	$.getJSON('/outbound_travels/data_to_suggest',function(data){
		$('#outbound_travel_place').autocomplete({
			source: data.place, 
			minLength: 0
		});
		$('#outbound_travel_payroll_effect').autocomplete({
			source: data.payroll_effect, 
			minLength: 0
		})
	});	
};    