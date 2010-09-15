module DataMapper
  module Events
    module Recurrence
      module InstanceMethods

        protected

        def next_year_in_recurrence
          if ( new_date = Time.utc(start.year, dates.first, dates.last, *start.to_a.slice(0,3).reverse) ) > start
            new_date
          else
            ny = start.year + interval
            nm = dates.first
            nd = [ dates.last, Time.days_in_month(nm, ny) ].min
            Time.utc(ny, nm, nd, *start.to_a.slice(0,3).reverse)
          end
        end

      end # InstanceMethods
    end # Recurrence
  end # Events
end # DataMapper

