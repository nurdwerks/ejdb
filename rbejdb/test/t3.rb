require "rbejdb"
require 'test/unit'

TESTDB_DIR = 'testdb'

unless File.exists?(TESTDB_DIR)
  Dir.mkdir TESTDB_DIR
end

Dir.chdir TESTDB_DIR

$jb = EJDB.open("tdbt3", EJDB::JBOWRITER | EJDB::JBOCREAT | EJDB::JBOTRUNC)

class EJDBAdvancedTestUnit < Test::Unit::TestCase
  RS = 100000
  QRS = 100000

  def test_ejdbadv1_performance
    assert_not_nil $jb
    assert $jb.open?

    puts "Generating test batch"

    recs = []
    letters = ('a'..'z').to_a
    (1..RS).each { |i|
      recs.push({
                    :ts => Time.now,
                    :rstring => (0...rand(128)).map { letters.sample }.join
                }
      )
      if i % 10000 == 0
        puts "#{i} records generated"
      end

    }

    puts "Saving..."

    st = Time.now
    recs.each { |rec| $jb.save("pcoll1", rec) }

    puts "Saved #{RS} objects, time: #{Time.now - st} s"
    assert_equal(RS, $jb.find("pcoll1", {}, :onlycount => true))

    puts "Quering..."

    st = Time.now
    (1..QRS).each {
      rec = recs.sample
      assert_equal(1, $jb.find("pcoll1", rec, :onlycount => true), "Strange record: #{rec}")
    }

    secs = Time.now - st
    puts "#{QRS} queries, time: #{secs} s, #{secs / QRS} s per query"

  end
end