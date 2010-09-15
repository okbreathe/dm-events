module DataMapper
  module Events
    module Recurrence
      module InstanceMethods

        protected

        # Occurences take place on specified [+dates+].
        # Interval specified which weeks are skipped
        # Go to first required day
        def next_week_in_recurrence
          if next_day = dates.find {|d| d > start.wday }
            start + (next_day - start.wday).days
          else
            start + begin
              (7 - start.wday)      +  # Beginning of next week
              ((interval - 1) * 7)  +  
              dates.first              
            end.days
          end
        end

      end # InstanceMethods
    end # Recurrence
  end # Events
end # DataMapper

