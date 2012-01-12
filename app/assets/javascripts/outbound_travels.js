function populateFormFields(){
	var places;
	var payroll_effect;
	$.getJSON('/outbound_travels/search_by_place',function(data){
		places = data;
	});
	$.getJSON('/outbound_travels/search_by_payroll_effect',function(data){
		payroll_effect = data;
	});
	debugger;
	$('#outbound_travel_place').autocomplete({
		source: places, 
		minLength: 0
	});
	$('#outbound_travel_payroll_effect').autocomplete({
		source: payroll_effect, 
		minLength: 0
	})
};    