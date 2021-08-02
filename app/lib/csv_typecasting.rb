# frozen_string_literal: true

# typecasting for fields that contain commas in our importers
module CsvTypecasting
  def to_float(value)
    value&.delete(',')&.to_f
  end

  def to_integer(value)
    value&.delete(',')&.to_i
  end

  def to_boolean(value)
    value == 'Yes'
  end
end
