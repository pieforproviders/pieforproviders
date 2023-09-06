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

  # rubocop:disable Metrics/AbcSize
  def find_matching_name(first_name, last_name)
    results = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_for_conditions([
                                                                                                     similarity_query,
                                                                                                     first_name,
                                                                                                     last_name,
                                                                                                     first_name,
                                                                                                     last_name
                                                                                                   ]))

    # rubocop:disable Rails/Output
    puts(' ')
    puts Rainbow("Analyzing child '#{first_name} #{last_name}'").bright
    # rubocop:enable Rails/Output
    if results.any?
      matching_child = results[0]
      average_score = (matching_child['sml_first_name'] + matching_child['sml_last_name']).to_f / 2

      { match_tag: match_tag(average_score), result_match: matching_child }

    else
      { match_tag: match_tag(0), result_match: matching_child }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def similarity_query
    <<-SQL.squish
        SELECT c.id, c.first_name,
          c.last_name, similarity(c.first_name, ?) AS sml_first_name,
          similarity(c.last_name, ?) AS sml_last_name
        FROM children c
        WHERE c.first_name % ?
        and c.last_name % ?
        ORDER BY c.last_name DESC
        LIMIT 1;
    SQL
  end
end
