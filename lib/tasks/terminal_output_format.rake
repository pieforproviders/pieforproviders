# frozen_string_literal: true

# This is meant to show how to use Rainbow and terminal table gems
desc 'Generate test table'
task test_table: :environment do
  puts Rainbow('This is an example').bright +
       Rainbow(' on how to use terminal colors').green +
       Rainbow(' and tables').yellow
  rows = []
  rows << [Rainbow('One').bright, 1]
  rows << [Rainbow('Two').yellow, 2]
  rows << [Rainbow('Three').italic, 3]
  table = Terminal::Table.new headings: %w[Word Number], rows: rows
  puts table
end
