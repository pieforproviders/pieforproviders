# frozen_string_literal: true

# Finds matching name from given string on the database
class NameMatchingEngine
  def initialize(first_name:, last_name:)
    @first_name = first_name
    @last_name = last_name
  end

  def call
    find_matching_name(@first_name, @last_name)
  end

  private

  def find_matching_name(first_name, last_name)
    results = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_for_conditions([
                                                                                                     similarity_query,
                                                                                                     first_name,
                                                                                                     last_name,
                                                                                                     first_name,
                                                                                                     last_name
                                                                                                   ]))

    # puts(' ')
    return unless results.any?

    results.sort_by do |match|
      avg = (match['sml_first_name'] + match['sml_last_name']).to_f / 2
      -avg
    end
  end

  def similarity_query
    <<-SQL.squish
        SELECT c.id, c.first_name,
          c.last_name, similarity(c.first_name, ?) AS sml_first_name,
          similarity(c.last_name, ?) AS sml_last_name
        FROM children c
        WHERE c.first_name % ?
        and c.last_name % ?
        ORDER BY c.last_name DESC
    SQL
  end
end
