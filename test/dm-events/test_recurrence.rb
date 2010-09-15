require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../data', __FILE__)

class TestDmEvents < Test::Unit::TestCase

  context "an instance of DM::Events::Recurrence" do
    setup do
      stub(Time).now{ now }
      @rec = ::EventRecurrence.new
    end

    should "show you all the recurrence events in a range" do
      @rec.every = :day
      @rec.on    = 5
      @event     = Event.new
      stub(@rec).event { @event }
      mock(EventRecurrence).all({}) { [@rec] }
      recurrence = EventRecurrence.in_range(now, now+30.days)
      assert_equal @event, recurrence.keys.first
      assert_equal 30, recurrence.values.first.length
    end

    should "not remove the event when it is destroyed" do
      event      = Event.create(:start => now, :end => now + 1.day, :every => :day)
      recurrence = event.recurrence
      recurrence.destroy
      assert_nil EventRecurrence.get(recurrence.id)
      assert_not_nil Event.get(event.id)
    end

    should "allow setting the interval" do
      @rec.interval = "bimonthly"
      assert_equal 2, @rec.attribute_get(:interval)
      @rec.interval = :quarterly
      assert_equal 3, @rec.interval 
      @rec.interval = :foo
      assert_equal 1, @rec.interval 
    end

  end

end
