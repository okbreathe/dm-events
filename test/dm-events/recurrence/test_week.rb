require File.expand_path('../../../helper', __FILE__)
require File.expand_path('../../../data', __FILE__)

class TestDmEvents < Test::Unit::TestCase

  context "an instance of DM::Events::Recurrence" do

    context "with weekly frequency" do
      setup do
        stub(Time).now{ now }
        @rec = ::EventRecurrence.new
        @rec.every = :week
      end

      should "work" do
        @rec.on = [1,2,3]
        assert_equal "week", @rec.frequency
        assert_equal [1,2,3], @rec.dates
      end

      should "convert string dates to numbers" do
        @rec.on = ["monday", "tues", "wednesday"]
        assert_equal [1,2,3], @rec.dates
      end

      should "ensure that they are unique" do
        @rec.on = ["monday", "monday", "monday", "tuesday", "tuesday"]
        assert_equal [1,2], @rec.dates
      end

      should "only accept up to 6 inputs" do
        @rec.on = ["monday", "monday", "monday", "monday", "monday", "monday", "friday"]
        assert_equal [1], @rec.dates
      end

      should "fail with invalid input" do
        assert_raise ArgumentError do
          @rec.on = "invalid"
        end
        assert_raise ArgumentError do
          @rec.on = 0
        end
        assert_raise ArgumentError do
          @rec.on = 1000
        end
      end

      should "allow you to get the date of occurence" do
        assert_equal now, @rec.to_date
      end

      context "getting the next occurence" do

        should "without a date default to Monday" do
          assert_equal now.next_week.beginning_of_week, @rec.next.to_date
        end

        should "allow you to get the next occurence" do
          @rec.on = :wednesday
          assert_equal (now + 1.day), @rec.next.to_date
        end

        should "account for intervals" do
          @rec.on       = :monday
          @rec.interval = 2
          assert_equal (now + 2.weeks).beginning_of_week, @rec.next.to_date
        end

      end

      should "show you all the recurrence events in a range" do
        @rec.on       = :monday # Every other monday
        @rec.interval = 2
        range = @rec.in_range(now, now+30.days)
        assert_equal Time.gm(2010,6,14), range.first
        assert_equal Time.gm(2010,6,28), range.last
        assert_equal 2, range.length
      end

    end # context "with weekly frequency"

  end

end


