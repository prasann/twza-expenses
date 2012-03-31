// TODO: Not sure whether this is even being used
$(document).ready(function() {
    var _this = this;
    display_cash_handover_section();
    validate_row_manipulations();
    $(function($) {
        $('.handover_selector').click(function(){
            $('.cash_handover_selector').hide();
            $('.cash_handover_section').show();
        });

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
            window.location = "/expense_settlements/" + $("#expense_settlement_outbound_travel_id").val() + "/load_by_travel?" + query_str;
        });

        $('.add_row').live("click", function() {
            var handover_section = $(this).parents().find('.cash_handovers');
            var cash_handovers = handover_section.find('.cash_handover');
            var display_element = cash_handovers.last();
            var cloned_element = display_element.clone();
            cloned_element.find(':input').val('');
            var rowColorClasses = ['even','odd'];
            for (var index in rowColorClasses)
                cloned_element.removeClass(rowColorClasses[index]);
            if (cash_handovers.size() % 2 == 1)
                cloned_element.addClass('odd');
            handover_section.append(cloned_element);
            cloned_element.find('.delete_row').show();
            cloned_element.find('.id').remove();
            validate_row_manipulations();
        });

        $('.delete_row').live("click",function(event){ 
            var _this = this;
            var cash_handover = $(this).parents('.cash_handover');
            var input = cash_handover.next();
            if (input != null && input.is('input')){
                $.ajax({
                      type: 'POST',
                      url: '/expense_settlements/delete_cash_handover',
                      data: {
                        id: input.val()
                      },
                      success: function(data){
                        cash_handover.last().remove(); 
                      }
                    });
                }else{
                    cash_handover.last().remove();    
                }      
            validate_row_manipulations();
        });

        $('.generate_settlement').click(function(event){
            var cash_handovers_section = $('.cash_handovers');
            cash_handovers_section.find('.cash_handover').each(function(index,item){
                var amount = $(item).find('.amount');
                var currency = $(item).find('.handover_currency');
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
                set_index_nested_form_attribute(amount, index);
                set_index_nested_form_attribute(currency, index);
                set_index_nested_form_attribute($(item).find('.conversion_rate'), index);
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

    function validate_row_manipulations() {
        var cash_handover_items = $('.cash_handovers').find('.cash_handover');
        if (cash_handover_items && cash_handover_items.size() > 0) {
            var last_cash_handover = cash_handover_items.last();

            register_currencies_autocomplete(last_cash_handover);

            last_cash_handover.find('.add_row').show();

            cash_handover_items.first().find('.delete_row').hide();
        }
    }

    function display_cash_handover_section() {
       var cash_handover_items = $('.cash_handovers').find('.cash_handover');
       if (cash_handover_items.size() == 0) {
           $('.cash_handover_section').hide();
           $('.cash_handover_selector').show();
       }
    }

    function register_currencies_autocomplete(element) {
        var down_arrow_event = jQuery.Event("keydown");
        var applicable_currencies = ($('#applicable_currencies').val()).split(' ');
        element.find($('.handover_currency')).autocomplete({source: applicable_currencies, minLength: 0})
            .focus(function(){
                $(this).trigger(down_arrow_event);
            });
    }
});
