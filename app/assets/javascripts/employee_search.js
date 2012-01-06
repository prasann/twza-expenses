$(document).ready(function(){
$('.emp_name').autocomplete({
   source: '/profiles/search_by_name', 
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

   }
})
    $('.emp_id').autocomplete({
    source: '/profiles/search_by_id',
    minLength: 2,
    select: function(event, ui) {
        $('.no_emp').hide();
        name_id = ui.item.value.split('-');
        $('.emp_id').val(name_id[1]);
        $('.emp_name').val(name_id[0]);
        return false;
        },
    change: function(event, ui) {
    $('.emp_names').val('');
    $('.no_emp').show();
   }
})
});