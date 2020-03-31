# frozen_string_literal: true

namespace :start do
  task development: :environment do
    exec 'heroku local -f Procfile.dev'
  end
end

desc 'Start development server'
task start: 'start:development'
