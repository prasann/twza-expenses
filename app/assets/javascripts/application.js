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

// TODO: The above require tree is bad - it will send the all js files for all views
// TODO: Move this to the specific pages that need these functions defined
$(document).ready(function() {
  $.datepicker.setDefaults({
    changeMonth: true,
    changeYear: true
  });

  $('.date_picker').datepicker({
    dateFormat : 'dd-M-yy'
  });
});
