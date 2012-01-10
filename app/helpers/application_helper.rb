module ApplicationHelper
  def date_fmt(date)
    if !date.nil?
      return date.strftime("%d-%b-%Y");
    end
  end

  def format_two_decimal_places(number)
	(number*100).round.to_f/100
  end
end
