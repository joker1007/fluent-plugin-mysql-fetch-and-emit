require "helper"
require "fluent/plugin/out_mysql_fetch_and_emit.rb"

class MysqlFetchAndEmitOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "mysql_connect" do
    p mysql_client.query("SHOW DATABASES")
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::MysqlFetchAndEmitOutput).configure(conf)
  end

  def mysql_client
    Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "")
  end
end
