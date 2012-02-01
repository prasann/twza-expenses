module DateHelper
  def self.date_fmt(date)
    date.strftime("%d-%b-%Y") if !date.nil?
  end

  def self.date_from_str(date_str)
    Date.parse(date_str) rescue nil
  end
end
