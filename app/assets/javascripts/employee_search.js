$(document).ready(function(){
$('.emp_name').autocomplete({
   source: '/profiles/list', 
   minLength: 2,
   select: function(event, ui) {
   },
   noresults: function() {
   },
   search: function(event, ui){
     alert('searching');
   }
})
});
