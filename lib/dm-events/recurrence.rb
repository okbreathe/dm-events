Dir[File.join(File.dirname(__FILE__), 'recurrence', '*.rb')].each{|f| require f }

module DataMapper
  module Events
    module Recurrence

      DATES_MAP = {
        :day       => { "mon" => 1, "tue" => 2, "wed" => 3, "thu" => 4, "fri" => 5, "sat" => 6, "sun" => 7 },
        :month     => { "jan" => 1, "feb" => 2, "mar" => 3, "apr" => 4,  "may" => 5,  "jun" => 6, 
                        "jul" => 7, "aug" => 8, "sep" => 9, "oct" => 10, "nov" => 11, "dec" => 12 },
        :cardinals => {:first => 1, :second => 2, :third => 3, :fourth => 4, :fifth => 5, :last => 5}
      }

      # This only applies when frequency is year or month
      INTERVALS_MAP = { "bimonthly"  => 2, "quarterly"  => 3 }
      INTERVALS_MAP.default = 1
      FREQUENCY_MAP = [:day,:week,:month,:year]

      # [+:until+]
      #   Specifies a limiting date and time after which no recurrences will be
      #   generated.
      #
      # [+:frequency+] 
      #   Specifies the frequency at which this event recurs.
      #
      # [+:every+]
      #   Alias for :frequency
      #
      # [+:interval+] 
      #   The number of intervals at an event's frequency in between occurrences of
      #   the event. For instance, if an event occurs every other week, it will have a
      #   frequency of 'week' and an interval of 2. Default: 1.
      #
      # [+:dates+]
      #   The dates of the interval. Meaning changes based on the frequency.
      #
      # [:on]
      #   Alias for :dates
      def self.extended(base)
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          include DataMapper::Resource unless ancestors.include?(::DataMapper::Resource)
          include DataMapper::Events::Recurrence::InstanceMethods

          property :id,         Serial unless properties.named?(:id)
          property :until,      DateTime
          property :frequency,  Integer, :max => 1, :required => true # XXX Workaround for buggy Enum on DM 1.0.X
          property :interval,   Integer, :default => 1
          property :dates,      Yaml # Array, XXX Maybe rename occurence

          has 1, :#{DataMapper::Events.event_name}, :constraint => :set_nil

          include InstanceMethods
          extend ClassMethods

          # XXX Workaround for buggy Enum on DM 1.0.X
          def frequency=(val)
            if f = FREQUENCY_MAP.index(val.to_sym)
              attribute_set(:frequency, f)
            end
          end

          def frequency
            if f = attribute_get(:frequency)
              FREQUENCY_MAP[f].to_s
            end
          end

          alias :every  :frequency
          alias :every= :frequency=
        RUBY
      end # self.extended

      module ClassMethods

        # Find all the recurrences in a specified range
        # TODO Limit won't work here as its a DM option
        # ==== Returns
        # {Event => [Dates]}
        def in_range(*args)
          opts = args.last.kind_of?(Hash) ? args.pop : {}
          all(opts).inject({}) do |m,r|
            d          = r.in_range(*args,opts.except(:limit))
            m[r.event] = d unless d.empty?
            m
          end
        end
      end

      module InstanceMethods

        def self.included(base)
          # Override accessors
          base.class_eval do

            # The allowed number and the meaning of the dates will vary depending on the frequency
            # Frequency - Options
            #
            # [+day+]   - N/A
            #   Dates used with a frequency of "day" will be ignored.
            #
            # [+week+]  - [day_of_the_week] 
            #   Can specify up to six values.
            #   Values can be an integer, or a string (e.g. 1 = "Monday")
            #
            # [+month+] - [day]
            #   Monthly frequency has a few more options available
            #   It can either be an integer from 1 to 31
            #     :on => 1
            #     :on => 15
            #
            #   Or a combination of a cardinal value followed by one or more days of the week
            #     :on => [:first, :thu]
            #       Will reoccur on the first Thursday 
            #     :on => [:last, 3] 
            #       Will reoccur on the last Wednesday (3 = Wednesday) of the month
            #     :on => [:last, :monday, :first, :thursday] 
            #       Will reoccur on the first thursday of the month and the last monday of the month
            #     :on => [:last, :monday, :friday] 
            #       Will reoccur on the last monday and friday of the month
            #
            #   The trick here is that the specified dates must be separated by cardinals
            #
            # [+year+]  - [month, day]
            #   At most two values. Any other values will be ignored.
            #   Month can be a string or a number. 
            #   If the day is left out it is assumed to be the first of the month
            #
            # All dates given as strings are stored as integer values
            def dates=(val)
              val = [*val]
              attribute_set(:dates, 
                case frequency.to_s
                when "day"    then nil
                when "week"   then val.slice(0,5).map  {|v| valid_day_of_week(v)  }.uniq.sort
                when "month"  then valid_month_interval(val)
                when "year"   then valid_date(val)
                end
              )
            end

            alias :on= :dates=

            def dates
              @dates ||= attribute_get(:dates) || begin
                case frequency 
                when "week"   then [1]   # monday
                when "month"  then [1]   # first of the month
                when "year"   then [1,1] # january 1st
                end
              end
            end

            alias :on  :dates

            # TODO Need better validation
            def interval=(val)
              attribute_set(:interval,val.kind_of?(Numeric) ? val : INTERVALS_MAP[val.to_s])
            end

          end
        end

        def start
          @start_time ||= Time.now.utc
        end

        def start=(val)
          @start_time = (val.kind_of?(Time) ? val : val.to_time).utc
        end

        alias :to_date :start

        def next
          (n = dup).start = self.send(:"next_#{frequency}_in_recurrence")
          n
        end

        # Same as #next but replaces the recurrence
        def next!
          self.start = self.send(:"next_#{frequency}_in_recurrence") 
          self
        end

        # Given a recurrence rule, calculate all the dates that fall
        # between in the given range.
        # ==== Arguments
        # Start/End Time or Range
        #
        # recurrence.in_range? Time.now, Time.now+24*60*60
        #
        # OR
        #
        # recurrence.in_range? Time.now..(Time.now+30.days)
        #
        # ==== Options
        # [+:limit+]
        #   Limit the number of potential dates returned
        #
        # ==== Returns
        # [Time] - An array of time objects for the recurrence, within the given range
        #
        def in_range(*args)
          opts   = args.last.kind_of?(Hash) ? args.pop : {}
          limit  = opts[:limit]
          count  = 1
          t_start, t_end = args.first.kind_of?(Range) ? [args.first.first, args.first.last] : [args.first,args.last]

          raise ArgumentError, "must be a range or two date/time objects" unless t_start and t_end

          self.start = t_start

          @in_range ||= begin
            result = []
            loop do
              next!
              break if count   > limit if limit
              break if to_date > t_end
              result << to_date
              count  += 1
            end

            result
          end
        end

        def in_range!(*args)
          @in_range = nil
          in_range(*args)
        end

        private

        # If the first value is a cardinal value like :first, or :last then 
        # We will assume that the construct is that of ":on => :first, :monday"
        # Internally, if the dates array if a hash then we will be looking
        # for the former construct, if an array, then we'll be looking for
        # individual dates
        def valid_month_interval(arr)
          if k = DATES_MAP[:cardinals][arr.first] 
            [k, valid_day_of_week(arr.last)]
          else
            arr.slice(0,1).map {|v| valid_month_date(v) }.uniq.sort
          end
        end

        def valid_date(arr)
          m = valid_month(arr.first)
          d = valid_date_in_month(arr[1],m)
          [m,d]
        end

        def valid_month_date(str)
          i = str.to_i
          (i >= 1 and i <= 31) ? i : raise(ArgumentError, "invalid date #{str}") 
        end

        # If the given string or integer is valid for the range, then it will
        # return an integer
        # Checks to make sure its a valid date
        def valid_day_of_week(str)
          n = str.kind_of?(Numeric) ? str : (DATES_MAP[:day][str.to_s.downcase[0,3]]).to_i
          (n >= 1 and n <= 7) ? n : raise(ArgumentError, "invalid day of the week `#{str}`") 
        end

        # TODO error message is poor because d and m are integers
        def valid_date_in_month(d,m)
          d >= 1 and Time.days_in_month(m,start.year) >= d ? d : raise(ArgumentError, "invalid day #{d} for #{m}") 
        end

        def valid_month(str)
          n = str.kind_of?(Numeric) ? str : (DATES_MAP[:month][str.to_s.downcase[0,3]]).to_i 
          (n >= 1 and n <= 12) ? n : raise(ArgumentError, "invalid month `#{str}`") 
        end

      end # InstanceMethods

    end # Recurrence
  end # Events
end # DataMapper
