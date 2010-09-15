module DataMapper
  module Events
    module Recurrence
      module InstanceMethods

        protected

        def next_day_in_recurrence   
          d  = start
          d += interval.days
        end

      end # InstanceMethods
    end # Recurrence
  end # Events
end # DataMapper
