$(document).ready(function(){
	$(function($){
		$('#expense_report_accordion').accordion({
			active: false,
			autoHeight: false,
    		collapsible: true
		});

		$("#expense_report_accordion h2 input").click(function(evt) { 
        	evt.stopPropagation()
        	if($(this).attr('checked') == 'checked')
        		$('#'+$(this).attr('name')+'_table').find($('input')).attr('checked','checked')
        	else
        		$('#'+$(this).attr('name')+'_table').find($('input')).removeAttr('checked')	
    	});

     $(".refresh").change(function(){
       query_str = "forex_from=" + $('#forex_from').val() +"&forex_to="+ $('#forex_to').val() + "&expense_from="+ $('#expense_from').val() + "&expense_to="+ $('#expense_to').val();
       window.location = "/expense_report/load_by_travel/" + $("#travel_id").val() + "?" +query_str;
     }); 
	})     
});
