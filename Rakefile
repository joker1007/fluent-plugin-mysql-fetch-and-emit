require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs.push("lib", "test")
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
  t.warning = true
end

task default: [:test]

namespace :circleci do
  namespace :db do
    task :create do
      require "mysql2"

      client = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "", database: "sample")
      client.query("CREATE TABLE users (id INT unsigned NOT NULL AUTO_INCREMENT, name VARCHAR(191) NOT NULL, PRIMARY KEY (id))")
    end
  end
end
