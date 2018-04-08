# fluent-plugin-mysql-fetch-and-emit
[![CircleCI](https://circleci.com/gh/joker1007/fluent-plugin-mysql-fetch-and-emit.svg?style=svg)](https://circleci.com/gh/joker1007/fluent-plugin-mysql-fetch-and-emit)

[Fluentd](https://fluentd.org/) output plugin to fetch from mysql by fluentd record and re-emit fetched record.

## Installation

### RubyGems

```
$ gem install fluent-plugin-mysql-fetch-and-emit
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-mysql-fetch-and-emit"
```

And then execute:

```
$ bundle
```

## Example

```
<match tag>
  @type mysql_fetch_and_emit

  host 127.0.0.1
  username root
  password password
  database db
  table users

  record_key id

  tag new_tag
</match>

<match new_tag>
  @type stdout
</match>
```

## Record Matching

```
<match tag>
  @type mysql_fetch_and_emit

  host 127.0.0.1
  username root
  password password
  database db
  table users

  record_key id

  tag new_tag

  <record_matching_key>
    fluentd_record_key email
    mysql_record_key email
  </record_matching_key>
</match>

<match new_tag>
  @type stdout
</match>
```

If fluentd record has email and match email value of mysql record,
plugin merges them.
You can set priority of merged records by `merge_priority`.

If `remove_keys` has some values,
plugin remove key from fluentd record before merging.

## Plugin helpers

* [event_emitter](https://docs.fluentd.org/v1.0/articles/api-plugin-helper-event_emitter)
* [record_accessor](https://docs.fluentd.org/v1.0/articles/api-plugin-helper-record_accessor)

* See also: [Output Plugin Overview](https://docs.fluentd.org/v1.0/articles/output-plugin-overview)

## Configuration

### host (string) (optional)

Database host.

Default value: `127.0.0.1`.

### port (integer) (optional)

Database port.

Default value: `3306`.

### database (string) (required)

Database name.

### username (string) (required)

Database user.

### password (string) (optional)

Database password.

Default value: ``.

### sslkey (string) (optional)

SSL key.

### sslcert (string) (optional)

SSL cert.

### sslca (string) (optional)

SSL CA.

### sslcapath (string) (optional)

SSL CA path.

### sslcipher (string) (optional)

SSL cipher.

### sslverify (bool) (optional)

SSL Verify Server Certificate.

### table (string) (required)

Database table name.

### tag (string) (required)

New tag.

### record_key (string) (required)

Use the record value for where condition. (record_accessor format)

### additional_condition (string) (optional)

Append this value to where clause.

### where_column (string) (optional)

Database column name for where condition.

### column_names (array) (optional)

Select column names.

Default value: `["*"]`.

### \<record_matching_key\> section (optional) (multiple)

#### fluentd_record_key (string) (required)

Fluentd record key to identify target to merge with mysql record

#### mysql_record_key (string) (required)

Mysql record column name to identify target to merge with fluentd record

### merge_priority (enum) (optional)

Preserve data priority. If this is set :mysql, prioritize database record data.

Available values: fluentd, mysql

Default value: `fluentd`.

### remove_keys (array) (optional)

A list of keys to delete from fluentd record

Default value: `[]`.

### \<buffer\> section (optional) (multiple)

#### chunk_limit_records () (optional)

Default value: `1000`.


## Copyright

* Copyright(c) 2018- joker1007
* License
  * Apache License, Version 2.0
