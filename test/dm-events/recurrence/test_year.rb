require File.expand_path('../../../helper', __FILE__)
require File.expand_path('../../../data', __FILE__)

class TestDmEvents < Test::Unit::TestCase

  context "an instance of DM::Events::Recurrence" do

    context "with yearly frequency" do
      setup do
        stub(Time).now{ now }
        @rec = ::EventRecurrence.new
        @rec.every= :year
      end

      should "work" do
        @rec.on= [1,2]
        assert_equal "year", @rec.frequency
        assert_equal [1,2], @rec.dates
      end

      should "convert string months to numbers" do
        @rec.on= ["January",3]
        assert_equal [1,3], @rec.dates
        @rec.on= ["dec",3]
        assert_equal [12,3], @rec.dates
        @rec.on= ["julY",3]
        assert_equal [7,3], @rec.dates
      end

      should "only accept up to 2 inputs" do
        @rec.on= ["Septem",1,2,3]
        assert_equal [9,1], @rec.dates
      end

      should "fail with invalid input" do
        assert_raise ArgumentError do
          @rec.on= ["invalid"]
        end
        assert_raise ArgumentError do
          @rec.on= [0]
        end
        assert_raise ArgumentError do
          @rec.on= [1000]
        end
      end

      should "ensure that the day is a valid day for the given month" do
        assert_raises ArgumentError do
          @rec.dates = ["Jan", 40]
        end
      end

      context "getting the next occurence" do

        should "without a date default to Jan 1" do
          assert_equal now.next_year.beginning_of_year, @rec.next.to_date
        end

        should "allow you to get the next occurence" do
          @rec.on = [7,1]
          assert_equal now.next_month.beginning_of_month, @rec.next.to_date
        end

        should "account for intervals" do
          @rec.dates    = ["Jan", 1]
          @rec.interval = 2
          assert_equal (now.beginning_of_year + 2.years), @rec.next.to_date
        end

      end

      should "show you all the recurrence events in a range" do
        @rec.on = [7,1]
        range   = @rec.in_range(now.beginning_of_year, now.end_of_year)
        assert_equal Time.gm(2010,7,1), range.first
        assert_equal 1, range.length
      end

    end
  end

end
