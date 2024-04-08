# frozen_string_literal: true

# Actions for name matching engine results
class NameMatchingActions
  def initialize(match_children:, file_child:)
    @match_children = match_children
    @file_child = file_child
  end

  def call
    user_outputs
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def user_outputs
    # rubocop:disable Rails/Output
    @match_children.each do |match_child|
      match_tag = match_child[:match_tag]
      case match_tag
      when 'exact_match'
        return Child.find_by(
          first_name: @file_child[0], last_name: @file_child[1]
        )
      when 'close_match'
        rows = []
        puts Rainbow("This child doesn't exactly match P4P's child records").yellow

        rows << [Rainbow('We found: ').bright + Rainbow("#{@file_child[0]} #{@file_child[1]}").yellow]
        rows << [Rainbow('P4P has: ').bright +
                 Rainbow("#{match_child[:first_name]} #{match_child[:last_name]}").yellow]

        table = Terminal::Table.new(rows:)
        puts table

        $stdout.puts Rainbow('Is this the same child? Yes or No').yellow
        input = $stdin.gets.chomp

        if input.downcase == 'yes'
          puts Rainbow("Thanks, we'll upload this attendance!").green
          return Child.find_by(first_name: match_child[:first_name], last_name: match_child[:last_name])
        else
          puts Rainbow("Okay, we'll skip over this record.").yellow
          return nil
        end

      when 'no_match'
        puts Rainbow("There's no match for #{@file_child[0]} #{@file_child[1]}. Please check the file").red
        nil
      end
    end
  end
  # rubocop:enable Rails/Output
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
