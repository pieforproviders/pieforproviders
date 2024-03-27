# frozen_string_literal: true

# Finds matching name from given string on the database
# rubocop:disable Rails/Output
# rubocop:disable Metrics/MethodLength
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

    'exact_match' if score == 1
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
    puts(' ')
    if results.any?
      sort_results(results).map do |matching_child|
        average_score = matching_child[:score]
        matching_child[:match_tag] = match_tag(average_score)
        matching_child
      end
    else
      { match_tag: match_tag(0), result_match: nil }
    end
  end

  def sort_results(results)
    results_info = results.map do |result|
      { first_name: result['first_name'],
        last_name: result['last_name'],
        score: (result['sml_first_name'] + result['sml_last_name']).to_f / 2 }
    end
    results_info.sort_by { |item| -item[:score] }
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
        LIMIT 5;
    SQL
  end
end
# rubocop:enable Rails/Output
# rubocop:enable Metrics/MethodLength
