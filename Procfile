web: bundle exec puma -t 5:5 -p ${PORT:-3001} -e ${RACK_ENV:-development}
release: bundle exec rails db:structure:load db:migrate:with_data