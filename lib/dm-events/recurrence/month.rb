module DataMapper
  module Events
    module Recurrence
      module InstanceMethods

        protected

        def next_month_in_recurrence
          # Have a raw month from 0 to 11 interval
          raw = start.month + interval - 1
          ny  = start.year + raw / 12
          nm  = (raw % 12) + 1 # change back to ruby interval
          if dates.length > 1
            new_date_in_same_month = next_occurence_by_day(nm-1,ny)
            new_date_in_same_month > start ? new_date_in_same_month : next_occurence_by_day(nm,ny)
          else
            next_occurence_by_date(nm,ny)
          end
        end

        # hash
        def next_occurence_by_day(next_month,next_year)
          next_date      = Time.utc(next_year, next_month, 1, *start.to_a.slice(0,3).reverse)
          weekday, month = dates.last, next_date.month

          # Adjust week day
          to_add     = weekday - next_date.wday
          to_add    += 7 if to_add < 0
          to_add    += (dates.first - 1) * 7
          next_date += to_add.days

          # Go to the previous month if we lost it
          if next_date.month != month
            weeks = (next_date.day - 1) / 7 + 1
            next_date -= (weeks * 7).days
          end

          next_date
        end


        # array
        def next_occurence_by_date(next_month,next_year)
          if ( new_date = Time.utc(start.year, start.month, dates.first, *start.to_a.slice(0,3).reverse) ) > start
            new_date
          else
            next_day   = [ dates.first, Time.days_in_month(next_month, next_year) ].min
            Time.utc(next_year, next_month, next_day, *start.to_a.slice(0,3).reverse)
          end
        end


      end # InstanceMethods
    end # Recurrence
  end # Events
end # DataMapper

