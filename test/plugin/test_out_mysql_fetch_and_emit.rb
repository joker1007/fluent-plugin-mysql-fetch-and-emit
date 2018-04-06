require "helper"
require "fluent/plugin/out_mysql_fetch_and_emit.rb"

class MysqlFetchAndEmitOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup

    mysql_client.query("INSERT INTO users (id, name) VALUES (1, 'user1'), (2, 'user2'), (3, 'user3')")
  end

  teardown do
    mysql_client.query("TRUNCATE TABLE users")
  end

  test "mysql_connect" do
    results = mysql_client.query("SELECT * FROM users ORDER BY id")
    assert do
      results.to_a.map { |row| row["id"] } == [1, 2, 3]
    end
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::MysqlFetchAndEmitOutput).configure(conf)
  end

  def mysql_client
    Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "", database: "sample")
  end
end
