# frozen_string_literal: true

# Copay logic
class Copays
  # These are the list of valid copay frequencies
  # These correspond to an ENUM type defined in the Postgres DB
  COPAY_FREQUENCIES = %w[daily
                         weekly
                         monthly].freeze

  def self.frequencies
    COPAY_FREQUENCIES.index_by(&:to_sym)
  end
end
