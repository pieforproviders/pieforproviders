# frozen_string_literal: true

task :read_nebraska_rates, [:filename] => [:environment] do |_t, args|
  # got this format working from: https://stackoverflow.com/questions/1357639/how-to-pass-arguments-into-a-rake-task-with-environment-in-rails
  NebraskaRatesImporter.new(args[:filename]).call
end
