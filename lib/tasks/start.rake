# frozen_string_literal: true

namespace :start do
  task :development do
    exec 'heroku local -f Procfile.dev'
  end
end

desc 'Start development server'
task start: 'start:development'
