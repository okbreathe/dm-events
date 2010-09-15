require 'helper'
require 'data'

class TestDmEvents < Test::Unit::TestCase
  context "An Model implementing has_events" do

    setup do
       stub(Time).now{ now }
    end

    should "Be an event doer" do
      assert Event.has_events?
      assert !Pig.has_events?
    end

    should "not be polymorphic" do
      assert !Event.polymorphic?
    end

    context "that is a Polymorphic Event models" do
      should "be polymorphic" do
        assert PolymorphicEvent.polymorphic?
      end

      context "Finding, Creating and Updating" do

        setup do
          @pig = Pig.new(:name => "pig")
          @event = PolymorphicEvent.new(:start => now, :end => now)
          stub(@event).save { true }
        end

        should "allow you to get events for models" do
          mock(PolymorphicEvent).all({:eventable_type => Pig, :order => [:start.desc] })
          PolymorphicEvent.for(Pig)
        end

        should "allow you to get events for objects" do
          stub(@pig).id { 1 }
          mock(PolymorphicEvent).first({:eventable_type => Pig, :eventable_id => 1, :order => [:start.desc] })
          PolymorphicEvent.for(@pig)
        end

        should "allow you to create an event if it doesn't exist" do
          stub(@pig).id { 1 }
          date = now+1.day
          stub(PolymorphicEvent).for(@pig) { @event }
          PolymorphicEvent.update_or_create(@pig, :start => date, :end => date )
          assert_equal date, @event.start
          assert_equal date, @event.end
        end

        should "allow you to update an event if it exists" do
          stub(@pig).id { 1 }
          date = now+1.day
          mock(PolymorphicEvent).new({:eventable_type => "Pig", :eventable_id => 1}) { @event }
          PolymorphicEvent.update_or_create(@pig, :start => date, :end => date )
        end
      end

    end

  end

end
