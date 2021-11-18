# frozen_string_literal: true

namespace :api_docs do
  desc 'Generate API documentations'
  task :generate, %i[version] do |_, args|
    version = args.fetch(:version, 'v1')
    api_docs_path = "public/api_docs/#{version}"

    RSpec::Core::RakeTask.new(:api_spec) do |t|
      t.pattern = "spec/requests/api/#{version}"
      t.rspec_opts =
        "--require rails_helper -f Dox::Formatter --tag dox --order defined --out #{api_docs_path}/index.json"
    end

    Rake::Task['api_spec'].invoke

    `yarn redoc-cli bundle -o #{api_docs_path}/index.html #{api_docs_path}/index.json`
  end
end
