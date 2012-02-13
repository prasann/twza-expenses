module ImportHelper
 def self.to_date(cell_value)
    (cell_value.instance_of?(Date)) ? cell_value : nil
  end

  def self.to_str(cell_value)
    (cell_value.instance_of?(Date)) ? cell_value.to_s : cell_value
  end

  # TODO: This is built into Rails - look at String#pluralize(count)
  def self.pluralize(count, singular, plural=nil)
    if count == 1
      "1 #{singular}"
    elsif plural
      "#{count} #{plural}"
    else
      "#{count} #{singular}s"
    end
  end
end
