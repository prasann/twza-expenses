module NumberHelper
  def format_two_decimal_places(number)
    (number * 100).round.to_f / 100
  end
end
