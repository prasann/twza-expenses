// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .
$(document).ready(function(){
	$(function($) {
   		$('#menu').tabs({
			ajaxOptions: {
				error: function( xhr, status, index, anchor ) {
					$( anchor.hash ).html(
						"Couldn't load this tab. We'll try to fix this as soon as possible. " +
						"If this wouldn't be a demo." );
				}
			},
			select: function(event, ui){
   				 if(ui.index == 0){ window.location = "/outbound_travels#outbound_travels";}
   				 if(ui.index == 1){ window.location = "/forex_payments#forex_payments";} 
  			}
		});
	});  
	
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