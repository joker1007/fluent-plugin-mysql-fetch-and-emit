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

  CONFIG = <<~CONF
    host 127.0.0.1
    username root
    password ""
    database sample
    table users

    record_key id
    column_names ["id as foo", "name"]

    tag new_tag
  CONF

  test "configure" do
    driver = create_driver

    assert_equal("id", driver.instance.where_column_name)
  end

  sub_test_case "write" do
    test "single feed" do
      driver = create_driver

      driver.run do
        driver.feed("tag", Time.now.to_i, {"id" => "1"})
      end
      event = driver.events[0]
      assert_equal("new_tag", event[0])
      assert_kind_of(Float, event[1])
      assert_equal({"foo" => 1, "name" => "user1"}, event[2])
    end

    test "multiple feed" do
      driver = create_driver

      driver.run do
        driver.feed("tag", Time.now.to_i, {"id" => "1"})
        driver.feed("tag", Time.now.to_i, {"id" => "3"})
      end
      event1 = driver.events[0]
      event2 = driver.events[1]

      assert_equal("new_tag", event1[0])
      assert_kind_of(Float, event1[1])
      assert_equal({"foo" => 1, "name" => "user1"}, event1[2])

      assert_equal("new_tag", event2[0])
      assert_kind_of(Float, event2[1])
      assert_equal({"foo" => 3, "name" => "user3"}, event2[2])
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::MysqlFetchAndEmitOutput).configure(conf)
  end

  def mysql_client
    Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "", database: "sample")
  end
end
