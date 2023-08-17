# frozen_string_literal: true

task matching_results: :environment do
  # compare names
  children = [
    { first_name: 'Paisley ', last_name: 'Orosco-Thompson' },
    { first_name: 'Khaisyn', last_name: 'Cruz' },
    { first_name: 'Noah', last_name: 'Baxa' },
    { first_name: 'Matthew', last_name: 'Musolf' },
    { first_name: 'Evelyn', last_name: 'Baxa' },
    { first_name: 'Aubryana "Aubrey"', last_name:	'Koehler' },
    { first_name: 'Bryan (Bree)', last_name: 'Xoquic' },
    { first_name: 'mya', last_name: 'white' },
    { first_name: 'Adrianna Nichole', last_name: 'Fox' },
    { first_name: 'Roman', last_name: 'Hanson-Glosser' }
  ]

  children.each do |child|
    results = ActiveRecord::Base.connection.execute(similarity_query(child[:first_name], child[:last_name]))
    p "Analyzing child '#{child[:first_name]} #{child[:last_name]}'"
    if results.any?
      matching_child = results[0]
      p 'results in DB'
      p "first_name: #{matching_child['first_name']} (similarity score: #{matching_child['sml_first_name']})"
      p "last_name: #{matching_child['last_name']} (similarity score: #{matching_child['sml_last_name']})"
      $stdout.puts 'Is the same record?'
      input = $stdin.gets.chomp
      p "Your action selected is #{input}"
      p '---------------------------------------'
    else
      p 'NO RESULT FOUND'
    end
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
