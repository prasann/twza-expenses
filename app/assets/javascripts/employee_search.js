$(document).ready(function(){
$('.emp_name').autocomplete({
   source: '/profiles/list', 
   minLength: 2,
   select: function(event, ui) {
     $('.no_emp').hide();
     name_id = ui.item.value.split('-');
     $('.emp_name').val(name_id[0]);
     $('.emp_id').val(name_id[1]);
     return false;
   },
   change: function(event, ui) {
     $('.emp_id').val('');
     $('.no_emp').show();

   },
})
});
