function populateFormFields(){
	var places;
	$.getJSON('/outbound_travels/search_by_place',function(data){
		places = data;
	});
	$('#outbound_travel_place').autocomplete({
		source: places, 
		minLength: 0
	}) 
};    