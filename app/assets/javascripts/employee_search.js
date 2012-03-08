$(document).ready(function(){
  $('.emp_name, .emp_id').autocomplete({
    source: function(request, response) {
      var autocompleteUrl = this.element.attr('data-href');
      $.ajax({
        url: autocompleteUrl,
        data: {
          term: request.term
        },
        success: function(data) {
          response($.map(data, function(item) {
            return {
              label: item.common_name + " - " + item.employee_id,
              common_name: item.common_name,
              employee_id: item.employee_id
            }
          }));
        }
      });
    },
    minLength: 2,
    select: function(event, ui) {
      $('.no_emp').hide();
      $('.emp_name').val(ui.item.common_name);
      $('.emp_id').val(ui.item.employee_id);
      return false;
    }
  })
});
