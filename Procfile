web: bundle exec puma -t 5:5 -p ${PORT:-3001} -e ${RACK_ENV:-development}
release: bundle exec db:migrate:with_data