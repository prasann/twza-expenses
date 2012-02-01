function calculateTotal() {
  var total_amount = 0;
  $(':checked').each(function() {
    var expense_id = $(this).val();
    var amount = $("[name='expense_amount[" + expense_id + "]']").val();
    total_amount= parseFloat(total_amount)+parseFloat(amount);
  });
  $("#total_amount").text(total_amount);
};

$(document).ready(function() {
  $(".affects_total").change(calculateTotal);
});
