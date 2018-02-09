# frozen_string_literal: true

# Open up the Integer class to add a formatting method.
class Integer
  def to_comma_formatted
    to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1,')
  end
end
