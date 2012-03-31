$(document).ready(function(){
  $('.emp_name, .emp_id').autocomplete({
    source: function(request, response) {
      var autocompleteUrl = this.element.attr('data-href');
      var isEmpId = (this.element.attr('class').indexOf('emp_id') != -1);
      $.ajax({
        url: autocompleteUrl,
        data: {
          term: request.term
        },
        success: function(data) {
          response($.map(data, function(item) {
            var lbl;
            if (isEmpId == true) {
              lbl = item.employee_id + " - " + item.common_name;
            } else {
              lbl = item.common_name + " - " + item.employee_id;
            }
            return {
              label: lbl,
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
