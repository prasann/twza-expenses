$(document).ready(function() {
    var _this = this;
    show_add_in_last_cash_handover();
    $(function($) {
        $('#expense_report_accordion').accordion({
            active: false,
            autoHeight: false,
            collapsible: true
        });

        $("#expense_report_accordion h2 input").click(function(evt) {
            evt.stopPropagation();
            if ($(this).attr('checked') == 'checked') {
                $('#' + $(this).attr('name') + '_table').find($('input')).attr('checked', 'checked');
            } else {
                $('#' + $(this).attr('name') + '_table').find($('input')).removeAttr('checked');
            }
        });

        $(".refresh").change(function() {
            query_str = "forex_from=" + $('#forex_from').val() + "&forex_to=" + $('#forex_to').val() + "&expense_from=" + $('#expense_from').val() + "&expense_to=" + $('#expense_to').val();
            window.location = "/expense_settlements/load_by_travel/" + $("#travel_id").val() + "?" + query_str;
        });

        $('.add_row').live("click", function() {
            var handover_section = $(this).parents('.cash_handovers');
            var display_element = handover_section.find('.cash_handover').last();
            var cloned_element = display_element.clone();
            cloned_element.find(':input').val('');
            handover_section.append(cloned_element);
            display_element.find('.delete_row').show();
            show_add_in_last_cash_handover();
            $(this).remove();
        });

        $('.delete_row').live('click',function(){
           $(this).parents('.cash_handover').last().remove();
          show_add_in_last_cash_handover();
        });

        $('.generate_settlement').click(function(event){
            var cash_handovers_section = $('.cash_handovers');
            var handover_item_index = 0;
            cash_handovers_section.find('.cash_handover').each(function(index,item){
                var amount = $(item).find('.amount');
                var currency = $(item).find('.currency');
                if (amount.val() == '') {
                    $(item).remove();
                    return true;
                }
                if (parseInt(amount.val()) < 0) {
                  alert('Please enter a positive forex cash handover amount');
                  event.preventDefault();
                  return false;
                }
                if (currency.val() == '')  {
                  alert('Please select a currency from the list of applicable currencies')
                  event.preventDefault();
                  return false;
                }
                set_index_nested_form_attribute(amount, handover_item_index);
                set_index_nested_form_attribute(currency, handover_item_index);
                handover_item_index = handover_item_index + 1;
            })
        });
    })

    function search_and_replace(target, regex, replace_pattern) {
        regexp = new RegExp(regex, "g");
        return target.replace(regexp, replace_pattern);
    }

    function set_index_nested_form_attribute(target, index) {
        target = $(target);
        var id_regex = '(.+)(_attributes_)(\\d+)(.+)';
        target.attr('id', search_and_replace(target.attr('id'), id_regex, '$1$2' + index + '$4'));

        var name_regex = '(.+)(_attributes|\\[)(\\d+)(.+)';
        target.attr('name', search_and_replace(target.attr('name'), name_regex, '$1$2' + index + '$4'));

    }

    function show_add_in_last_cash_handover() {
      var cash_handover_items = $('.cash_handovers').find('.cash_handover');
      if (cash_handover_items && cash_handover_items.size() > 0)
        cash_handover_items.last().find('.add_row').show();
    }
});
