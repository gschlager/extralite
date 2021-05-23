# frozen_string_literal: true

require_relative 'helper'

class DatabaseTest < MiniTest::Test
  def setup
    @db = Extralite::Database.new('/tmp/extralite.db')
    @db.query('create table if not exists t (x,y,z)')
    @db.query('delete from t')
    @db.query('insert into t values (1, 2, 3)')
    @db.query('insert into t values (4, 5, 6)')
  end

  def test_database
    r = @db.query('select 1 as foo')
    assert_equal [{foo: 1}], r
  end

  def test_query
    r = @db.query('select * from t')
    assert_equal [{x: 1, y: 2, z: 3}, {x: 4, y: 5, z: 6}], r
  end

  def test_query_hash
    r = @db.query_hash('select * from t')
    assert_equal [{x: 1, y: 2, z: 3}, {x: 4, y: 5, z: 6}], r
  end

  def test_query_ary
    r = @db.query_ary('select * from t')
    assert_equal [[1, 2, 3], [4, 5, 6]], r
  end

  def test_query_single_column
    r = @db.query_single_column('select y from t')
    assert_equal [2, 5], r
  end

  def test_query_single_value
    r = @db.query_single_value('select z from t order by Z desc limit 1')
    assert_equal 6, r
  end

  def test_transaction
    error = nil
    begin
      @db.transaction do
        @db.query('insert into t values (7, 8, 9)')
        raise 'blah'
      end
    rescue => error
    end
    assert_kind_of RuntimeError, error
    assert_equal 'blah', error.message
    assert [2, 5], @db.query_single_column('select y from t')

    @db.transaction do
      @db.query('insert into t values (7, 8, 9)')
    end
    assert [2, 5, 8], @db.query_single_column('select y from t')

    

  end
end