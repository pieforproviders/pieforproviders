# frozen_string_literal: true

# Actions for name matching engine results
class NameMatchingActions
  def initialize(match_tag:, match_child:, file_child:, business:)
    @match_tag = match_tag
    @match_child = match_child
    @file_child = file_child
    @business = business
  end

  def call
    user_outputs
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def user_outputs
    # rubocop:disable Rails/Output
    case @match_tag
    when 'exact_match'
      @business.children.find_by(
        first_name: @file_child[0], last_name: @file_child[1]
      )
    when 'close_match'
      rows = []
      puts Rainbow("This child doesn't exactly match P4P's child records").yellow.bold

      rows << [Rainbow('We found: ').bright.yellow + Rainbow("#{@file_child[0]} #{@file_child[1]}").yellow]
      rows << [Rainbow('P4P has: ').bright.yellow +
               Rainbow("#{@match_child['first_name']} #{@match_child['last_name']}").yellow]

      table = Terminal::Table.new rows: rows
      puts table

      $stdout.puts Rainbow('Is this the same child? Yes or No').yellow
      input = $stdin.gets.chomp

      if input.downcase == 'yes'
        puts Rainbow("Thanks, we'll upload this attendance!").green
        @business.children.find_by(first_name: @match_child['first_name'], last_name: @match_child['last_name'])
      else
        puts Rainbow("Okay, we'll skip over this attendance.").yellow
        nil
      end

    when 'no_match'
      puts Rainbow("There's no match for #{@file_child[0]} #{@file_child[1]} on the system. Please check the file").red
      nil
    end
  end
  # rubocop:enable Rails/Output
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
