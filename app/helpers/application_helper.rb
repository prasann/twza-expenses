module ApplicationHelper
  # TODO: Remove this method and replace with the number_with_precision?
  def format_two_decimal_places(number)
    (number * 100).round.to_f / 100
  end

  def flash_message
    messages = ""

    [:notice, :info, :warning, :error, :success].each { |type|
      if flash[type]
        div_tag = content_tag :div, flash[type], :class => "#{type} notification"
        messages += div_tag
      end
    }
    messages << javascript_tag("$('.notification').fadeOut(5000);")
    messages.html_safe
  end

  def calculate_stay_duration(outbound_travel)
    # TODO: encapsulation?
    if outbound_travel.return_date.nil?
      date = DateHelper.date_from_str(outbound_travel.expected_return_date)
      return (date - outbound_travel.departure_date).to_i unless date.nil?
      return date
    else
      return (outbound_travel.return_date - outbound_travel.departure_date).to_i
    end
  end
end
