module ApplicationHelper
  def date_fmt(date)
    if !date.nil?
      return date.strftime("%d-%b-%Y");
    end
  end
end