#
# Copyright 2018- joker1007
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"
require "mysql2"

module Fluent
  module Plugin
    class MysqlFetchAndEmitOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("mysql_fetch_and_emit", self)

      helpers :event_emitter, :record_accessor

      config_param :host, :string, default: '127.0.0.1',
        desc: "Database host."
      config_param :port, :integer, default: 3306,
        desc: "Database port."
      config_param :database, :string,
        desc: "Database name."
      config_param :username, :string,
        desc: "Database user."
      config_param :password, :string, default: '', secret: true,
        desc: "Database password."
      config_param :sslkey, :string, default: nil,
        desc: "SSL key."
      config_param :sslcert, :string, default: nil,
        desc: "SSL cert."
      config_param :sslca, :string, default: nil,
        desc: "SSL CA."
      config_param :sslcapath, :string, default: nil,
        desc: "SSL CA path."
      config_param :sslcipher, :string, default: nil,
        desc: "SSL cipher."
      config_param :sslverify, :bool, default: nil,
        desc: "SSL Verify Server Certificate."

      config_param :table, :string,
        desc: "Database table name."

      config_param :tag, :string,
        desc: "New tag."

      config_param :record_key, :string,
        desc: "Use the record value for where condition. (record_accessor format)"
      config_param :where_column, :string, default: nil,
        desc: "Database column name for where condition."
      config_param :column_names, :array, value_type: :string, default: ["*"],
        desc: "Select column names."

      config_section :buffer do
        config_set_default :chunk_limit_records, 1000
      end

      def configure(conf)
        super
        @accessor_for_record_key = record_accessor_create(@record_key)
      end

      def format(tag, time, record)
        value = @accessor_for_record_key.call(record)
        case value
        when String, Integer, Float
          [tag, time, {"value" => value}].to_msgpack
        else
          @log.warn("Incoming record is omitted, Supported value type of `record_key` is String, Integer, Float")
          nil
        end
      end

      def formatted_to_msgpack_binary?
        true
      end

      def multi_workers_ready?
        true
      end

      def where_column_name
        @where_column || @record_key
      end

      def write(chunk)
        database, table = expand_placeholders(chunk.metadata)
        @handler = client(database)
        where_values = []
        chunk.msgpack_each do |tag, time, data|
          value = data["value"]
          case value
          when String
            where_values << "'" + Mysql2::Client.escape(value) + "'" if value
          when Integer, Float
            where_values << value.to_s if value
          end
        end
        where_condition = "WHERE #{where_column_name} IN (#{where_values.join(',')})"

        sql = "SELECT #{@column_names.join(", ")} FROM #{table} #{where_condition}"
        results = @handler.query(sql)

        time = Fluent::Clock.now
        results.each do |row|
          router.emit(@tag, time, row)
        end
      end

      def client(database)
        Mysql2::Client.new(
          host: @host,
          port: @port,
          username: @username,
          password: @password,
          database: database,
          sslkey: @sslkey,
          sslcert: @sslcert,
          sslca: @sslca,
          sslcapath: @sslcapath,
          sslcipher: @sslcipher,
          sslverify: @sslverify,
          flags: Mysql2::Client::MULTI_STATEMENTS
        )
      end

      def expand_placeholders(metadata)
        database = extract_placeholders(@database, metadata).gsub('.', '_')
        table = extract_placeholders(@table, metadata).gsub('.', '_')
        return database, table
      end
    end
  end
end
