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
              lbl = item.emp_id + " - " + item.emp_name;
            } else {
              lbl = item.emp_name + " - " + item.emp_id;
            }
            return {
              label: lbl,
              emp_name: item.emp_name,
              emp_id: item.emp_id
            }
          }));
        }
      });
    },
    minLength: 2,
    select: function(event, ui) {
      $('.no_emp').hide();
      $('.emp_name').val(ui.item.emp_name);
      $('.emp_id').val(ui.item.emp_id);
      return false;
    }
  })
});
