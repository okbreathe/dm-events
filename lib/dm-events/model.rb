module DataMapper
  module Events
    module Model

      def self.extended(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def creates_events(opts={})
          before :save do
            attrs = {}
            DataMapper::Events.event_model.create(attrs)
          end
        end
      end # InstanceMethods
    end # Model
  end # Events
end # DataMapper

