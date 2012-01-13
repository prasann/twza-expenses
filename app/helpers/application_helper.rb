module ApplicationHelper
  def date_fmt(date)
    if !date.nil?
      return date.strftime("%d-%b-%Y");
    end
  end

  def format_two_decimal_places(number)
    (number*100).round.to_f/100
  end

  def flash_message
    messages = ""

    [:notice, :info, :warning, :error, :success].each { |type|
      if flash[type]
        div_tag = content_tag :div, flash[type], :class => "#{type} notification"
        messages += div_tag
      end
    }
    messages << javascript_include_tag("$('.notification').fadeOut(5000);")
    messages.html_safe
  end
end
