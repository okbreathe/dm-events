module DataMapper
  module Events
    module Cancellation

      def self.extended(base)
        base.class_eval do 
          include DataMapper::Resource unless base < DataMapper::Resource

          property :id,   Serial unless base.properties.named?(:id)
          # The date of the recurrence of an event that should be cancelled. If the
          # event spans multiple days, it will be set to the first date on which the
          # recurrence to be cancelled falls.
          property :date, Integer

          include InstanceMethods
          extend  ClassMethods
        end # base.class_eval
      end # self.extended

      module ClassMethods
      end # ClassMethods

      module InstanceMethods
      end # InstanceMethods

    end # Event
  end # Events
end # DataMapper
