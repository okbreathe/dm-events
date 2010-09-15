require File.expand_path('../../../helper', __FILE__)
require File.expand_path('../../../data', __FILE__)

class TestDmEvents < Test::Unit::TestCase

  context "an instance of DM::Events::Recurrence" do

    context "with daily frequency" do
      setup do
        stub(Time).now{ now }
        @rec = ::EventRecurrence.new
        @rec.every = :day
        @rec.on    = 5
      end

      should "work" do
        assert_equal "day", @rec.frequency
      end

      should "not allow setting of the dates property" do
        assert_nil @rec.dates
      end

      should "allow you to get the date of occurence" do
        assert_equal now, @rec.to_date
      end

      should "allow you to get the next occurence" do
        assert_equal now+1.day, @rec.next.to_date
        @rec.interval = 3
        assert_equal now+3.day, @rec.next.to_date
      end

      should "allow chaining" do
        assert_equal now+4.day, @rec.next.next.next.next.to_date
      end

      should "show you all the recurrence events in a range" do
        range = @rec.in_range(now, now+30.days)
        assert_equal now+1.day, range.first
        assert_equal now+30.day, range.last
        assert_equal 30, range.length
      end

    end

  end

end

