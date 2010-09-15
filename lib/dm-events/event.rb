module DataMapper
  module Events
    module Event

      def self.extended(base)
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          include DataMapper::Resource unless ancestors.include?(::DataMapper::Resource)

          property :id,         Serial unless properties.named?(:id)
          property :parent_id,  Integer,  :required => false
          property :start,      DateTime, :required => true
          property :end,        DateTime, :required => false

          if polymorphic?
            property :eventable_id,   Integer
            property :eventable_type, String

            # Return a list of events for a given class or object
            def self.for(obj = nil, attrs = {})
              attrs[:order] ||= [:start.desc]
              if obj.class == Class
                all(attrs.merge({:eventable_type => obj}))
              else
                first(attrs.merge({:eventable_type => obj.class, :eventable_id => obj.id}))
              end
            end

            # Create a new event with the given attributes for the 
            # given object
            def self.update_or_create(obj, attrs = {})
              e = self.for(obj) || self.new({:eventable_id => obj.id, :eventable_type => obj.class.to_s})
              e.attributes = attrs
              e.save
            end

          end

          before :destroy do
            recurrence.destroy if recurrence
          end

          belongs_to :#{DataMapper::Events.recurrence_name}, :required => false

          include InstanceMethods
          extend  ClassMethods
        RUBY
          
      end # self.extended

      module ClassMethods

        # Allow creating the recurrence with event attributes
        def new(attrs={})
          r_attrs = attrs.inject({}) {|m,(k,v)| m[k] = attrs.delete(k) if [:every, :frequency, :on, :interval, :dates].include?(k); m } 
          attrs[DataMapper::Events.recurrence_name.to_sym] ||= r_attrs unless r_attrs.empty?
          super
        end

        # Returns all the events that are recurring events
        def recurring(opts={})
          all({DataMapper::Events.recurrence_key.not => nil}.merge(opts))
        end

        # Any recurring dates in the past are updated to their next
        # future occurrence
        def recurrence_to_events!(now = Time.now.utc)
          recurring.each {|r| r.recurrence_to_events!(now)}
        end

        # Any event that has yet to occur
        def future(opts={}, now = Time.now.utc)
          all({:start.gte => now}.merge(opts))
        end

        alias :upcoming :future

        # Any event that has already occurred
        def past(opts={}, now = Time.now.utc)
          all({:start.lt => now}.merge(opts))
        end

        # Retrieve all events in a range
        def between(s,e,opts={})
          all(opts.merge!(:start.lte  => e, :end.gte => s ))
        end
      end # ClassMethods

      module InstanceMethods

        # has the event already occurred?
        def past?(now = Time.now.utc)
          attribute_get(:end) > now
        end
        alias :finished? :past?

        # Next occurrence of the event
        def next
          recurrence.next if recurring?
        end

        # Generate events from a recurrence rule.
        #
        # * Events are generated from the start date of the last event in the
        #   event chain to the time given.
        #
        # * All events generated from recurrence rules have parent
        def recurrence_to_events!(now = Time.now.utc)
          return unless recurrence
          pid       = parent_id || id # if parent_id is nil then we're generating from the parent
          duration  = (self.end - self.start).to_i
          t_start   = end_of_chain.start.midnight.tomorrow # Every day after the current day
          recurrence.in_range(t_start, now).each do |t|
            self.class.create(:start => t, :end => t + duration, :parent_id => pid)
          end
        end

        def recurrence
          send(DataMapper::Events.recurrence_name)
        end

        def recurring?
          !!recurrence
        end

        protected

        # New events are calculated from the last event in the chain. If there
        # are no children yet, this will be the parent. 
        # All events generated from recurrence rules have parents
        def end_of_chain
          parent_id ? self.class.first(:parent_id => parent_id, :order => [:start.desc]) : self
        end

      end # InstanceMethods
    end # Event
  end # Events
end # DataMapper
