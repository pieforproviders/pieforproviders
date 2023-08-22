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

  def match_tag(score)
    return 'no_match' if score.zero?
    return 'close_match' if score.positive? && score <= 0.99
    return 'exact_match' if score == 1
  end

  private

  def find_matching_name(first_name, last_name)
    results = ActiveRecord::Base.connection.execute(similarity_query(first_name, last_name))
    p "Analyzing child '#{first_name} #{last_name}'"

    if results.any?
      matching_child = results[0]
      average_score = (matching_child['sml_first_name'] + matching_child['sml_last_name']).to_f / 2

      { match_tag: match_tag(average_score), result_match: matching_child }

    else
      # p 'NO RESULT FOUND'
      { match_tag: match_tag(0), result_match: matching_child }
    end
  end

  def similarity_query(first_name, last_name)
    <<-SQL.squish
        SELECT c.id, c.first_name,
          c.last_name, similarity(c.first_name, '#{first_name}') AS sml_first_name,
          similarity(c.last_name, '#{last_name}') AS sml_last_name
        FROM children c
        WHERE c.first_name % '#{first_name}'
        and c.last_name % '#{last_name}'
        ORDER BY c.last_name DESC
        LIMIT 1;
    SQL
  end
end
