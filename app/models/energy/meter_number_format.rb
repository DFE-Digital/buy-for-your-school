module Energy
  module MeterNumberFormat
    VALID_METER_NUMBER_REGEX = /\A[\d\-\s()\p{Zs}\p{Cf}]+\z/
  end
end
