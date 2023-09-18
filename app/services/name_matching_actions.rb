# frozen_string_literal: true

# Actions for name matching engine results
class NameMatchingActions
  def initialize(matches:, file_child:, business:)
    @file_child = file_child
    @matches = matches
    @business = business
    @best_match = nil
  end

  def call
    process_matches
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

  def match_tag(score)
    return 'no_match' if score.zero?
    return 'close_match' if score.positive? && score <= 0.99
    return 'exact_match' if score == 1
  end

  def match_score(child)
    (child['sml_first_name'] + child['sml_last_name']).to_f / 2
  end

  def process_matches
    @matches&.each do |match_child|
      @match = match_child
      match_score = match_score(match_child)
      @match_tag = match_tag(match_score)
      user_outputs
      break if @best_match.present?
    end
    @best_match
  end

  def user_outputs
    # rubocop:disable Rails/Output
    case @match_tag
    when 'exact_match'
      @best_match = @business.children.find_by(
        first_name: @match['first_name'], last_name: @match['last_name']
      )
    when 'close_match'
      matching_options("This child doesn't exactly match P4P's child records")
    when 'no_match'
      puts Rainbow("There's no match for #{@file_child[0]} #{@file_child[1]} on the system. Please check the file").red
      nil
    end
  end

  def matching_options(message)
    rows = []
    puts Rainbow(message).yellow

    rows << [Rainbow('We found: ').bright + Rainbow("#{@file_child[0]} #{@file_child[1]}").yellow]
    rows << [Rainbow('P4P has: ').bright +
             Rainbow("#{@match['first_name']} #{@match['last_name']}").yellow]

    table = Terminal::Table.new rows: rows
    puts table

    $stdout.puts Rainbow('Is this the same child? Yes or No').yellow
    input = $stdin.gets.chomp

    if input.downcase == 'yes'
      puts Rainbow("Thanks, we'll upload this attendance!").green
      @best_match = @business.children.find_by(first_name: @match['first_name'], last_name: @match['last_name'])
    else
      puts Rainbow("Okay, we'll skip over this attendance.").yellow
      nil
    end
  end
  # rubocop:enable Rails/Output
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
