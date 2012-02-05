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

// TODO: Move this to the specific pages that need these functions defined
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
        // TODO: This is somehow broken by Vijay - Need help to investigate and fix
        // TODO: Use url helpers rather than hardcoding the url
        if(ui.index == 0){ window.location = "/outbound_travels#outbound_travels";}
        if(ui.index == 1){ window.location = "/forex_payments#forex_payments";}
        if(ui.index == 2){ window.location = "/expense_settlements#expense_settlement";}
        if(ui.index == 3){ window.location = "/expense_reimbursements#expense_reimbursement";}
        if(ui.index == 4){ window.location = "/reports#reports";}
      }
    });

    $('.date_picker').datepicker({dateFormat: 'dd-M-yy'});
  });
});
