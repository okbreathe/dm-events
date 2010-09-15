require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../data', __FILE__)

class TestDmEvents < Test::Unit::TestCase

  context "An instance of DataMapper::Events::Event" do
    setup do
      stub(Time).now{ now }
    end

    context "without a recurring event" do

      setup do
        @event = Event.new(:start => now, :end => now + 1.day)
      end

      should "work" do
        assert_equal now, @event.start
        assert_equal now+1.day, @event.end
      end

      should "not be recurring" do
        assert !@event.recurring?
      end

    end

    context "with a recurring event" do

      setup do
        @event = Event.new(:start => now, :end => now + 1.day, :every => :month, :interval => 2, :on => 1)
      end

      should "remove the recurrence with the event" do
        event      = Event.create(:start => now, :end => now + 1.day, :every => :day)
        recurrence = event.recurrence
        assert_not_nil EventRecurrence.first
        event.destroy
        assert_nil EventRecurrence.first 
      end
      
      should "be recurring" do
        assert @event.recurring?
      end

      should "pass recurrence parameters to its recurrence" do
        assert_equal 2,       @event.recurrence.interval
        assert_equal [1],     @event.recurrence.dates
        assert_equal "month", @event.recurrence.frequency
      end

      should "should save the recurrence when saving the event" do
        @event.save
        assert Event.first.recurrence.kind_of?(EventRecurrence)
        Event.all.destroy!
      end

      context "updating individual recurrences" do
        setup do
          @e1 = Event.create(:start => now, :end => now + 1.day, :every => :week, :on => 1)
          @e2 = Event.create(:start => now, :end => now + 1.day, :every => :month, :on => 1)
        end

        should "create a new concrete event if the next occurence is in the past" do
          @e1.recurrence_to_events!(now+30.days)
          assert_equal [7,14,21,28], Event.all(:parent_id => @e1.id ).map{|e| e.start.day}
        end

        should "do nothing if the next occurence is in the future" do
          assert_equal [], Event.all(:parent_id => @e2.id)
        end

        teardown do
          Event.all.destroy
        end
      end

      context "updating multiple recurrences" do
        setup do
          @e1 = Event.create(:start => now, :end => now + 1.day, :every => :week, :on => 1)
          @e2 = Event.create(:start => now, :end => now + 1.day, :every => :week, :on => 2)
          @e3 = Event.create(:start => now, :end => now + 1.day, :every => :week, :on => 3)
        end

        should "work" do
          Event.recurrence_to_events!(now+30.days)
          assert_equal [7,14,21,28], Event.all(:parent_id => @e1.id ).map{|e| e.start.day}
          assert_equal [8,15,22,29], Event.all(:parent_id => @e2.id ).map{|e| e.start.day}
          assert_equal [9,16,23,30], Event.all(:parent_id => @e3.id ).map{|e| e.start.day}
        end

        teardown do
          Event.all.destroy
        end
      end

    end

  end
end
