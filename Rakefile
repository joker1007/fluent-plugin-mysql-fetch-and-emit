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
      client = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "")
      client.query("CREATE DATABASE sample")
      client.query("USE sample")
      client.query("CREATE TABLE users (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(191), PRIMARY KEY (id)")
    end
  end
end
