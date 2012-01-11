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
	})     
});