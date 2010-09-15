require File.expand_path('../../../helper', __FILE__)
require File.expand_path('../../../data', __FILE__)

class TestDmEvents < Test::Unit::TestCase

  context "an instance of DM::Events::Recurrence" do

    context "with monthly frequency" do
      setup do
        stub(Time).now{ now }
        @rec = ::EventRecurrence.new
        @rec.every = :month
      end

      should "only allow one numeric value" do
        @rec.on = [1,2,3]
        assert_equal "month", @rec.frequency
        assert_equal [1], @rec.dates
      end

      should "allow more human-readable definitions" do
        @rec.on = [:first, :thursday]
        assert_equal [ 1, 4 ], @rec.dates
        @rec.on = [:last, :tuesday]
        assert_equal [ 5, 2 ], @rec.dates
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

      context "getting the next occurence" do

        should "without a date default to Jan 1" do
          assert_equal now.next_month.beginning_of_month, @rec.next.to_date
        end

        should "allow you to get the next occurence" do
          @rec.on = [5]
          assert_equal (now + 4.days), @rec.next.to_date
          @rec.on = [15]
          assert_equal (now + 14.days), @rec.next.to_date
        end

        should "account for intervals" do
          @rec.on    = [1]
          @rec.interval = 2
          assert_equal (now.beginning_of_month + 2.months), @rec.next.to_date
        end

        should "allow you to specify cardinal values" do
          @rec.on = [ :first, :sunday ]
          assert_equal now.end_of_week.beginning_of_day, @rec.next.to_date
          assert_equal 0, @rec.next.to_date.wday

          @rec.on = [ :last, :tuesday ]
          assert_equal Time.utc(2010,6,29), @rec.next.to_date
          assert_equal 2, @rec.next.to_date.wday

          @rec.on = [ :third, :monday ]
          assert_equal Time.utc(2010,6,21), @rec.next.to_date
          assert_equal 1, @rec.next.to_date.wday
        end

        should "allow you to set an interval with cardinal values" do
          @rec.on = [ :first, :sunday ]
          @rec.interval = 2
          assert_equal Time.utc(2010,7,4), @rec.next.to_date
          assert_equal 0, @rec.next.to_date.wday

          @rec.on = [ :third, :monday ]
          @rec.interval = :quarterly
          assert_equal Time.utc(2010,8,16), @rec.next.to_date
          assert_equal 1, @rec.next.to_date.wday

          @rec.on = [ :last, :friday ]
          @rec.interval = :bimonthly
          assert_equal Time.utc(2010,7,30), @rec.next.to_date
          assert_equal 5, @rec.next.to_date.wday
        end
      end

      should "show you all the recurrence events in a range" do
        @rec.on = [ :first, :sunday ]
        range   = @rec.in_range(now, now+30.days)
        assert_equal Time.gm(2010,6,6), range.first
        assert_equal 1, range.length
      end

    end

  end

end


