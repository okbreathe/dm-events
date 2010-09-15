require "active_support/inflector" 
require "active_support/time" 
require 'dm-core'
require 'dm-types'
require 'dm-constraints'
require 'dm-is-tree'

Dir[File.join(File.dirname(__FILE__), 'dm-events', '*.rb')].each{|f| require f }

module DataMapper
  module Events

    # This method is called on the event model
    #
    # Options
    #
    # [+:recurrence_model+]
    #   Name of the model to use for recurrences
    #
    # [+:cancellation_model+]
    #   Name of the model to use for cancellations
    #
    # [+:non_cancelling+]
    #   If true, no cancellation model will be created. Default: true
    #
    # [+:non_recurring+]
    #   If true, no recurrence model will be created. Default: false
    #
    # [+:polymorphic+]
    #   If true, will add a eventable_type, eventable_id 
    #   property to the model.
    #
    def has_events(opts={})
      @has_events = true

      @dm_events_options = { 
        :event_model        =>  self.to_s,
        :recurrence_model   => "EventRecurrence",
        :cancellation_model => "EventCancellation",
        :non_cancelling     => true
      }.merge(opts)
      DataMapper::Events.generate_accessors(@dm_events_options)
      DataMapper::Events.generate_models(@dm_events_options)
    end # has_events

    def has_events?
      !!@has_events
    end

    def polymorphic?
      !!@dm_events_options[:polymorphic]
    end

    def self.generate_accessors(opts)
      %w(event recurrence cancellation).each do |opt|
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.#{opt}_model; "#{opts[:"#{opt}_model"]}"; end
          def self.#{opt}_name;  @_#{opt}_name ||= #{opt}_model.underscore; end
          def self.#{opt}_key;   @_#{opt}_key  ||= #{opt}_model.foreign_key.to_sym; end
        RUBY
      end
    end

    def self.generate_models(opts)
      generate_model(self.recurrence_model,   DataMapper::Events::Recurrence)   unless opts[:non_recurring]
      generate_model(self.event_model,        DataMapper::Events::Event)
      generate_model(self.cancellation_model, DataMapper::Events::Cancellation) unless opts[:non_cancelling]
    end

    def self.generate_model(name, extensions)
      model = ::Object.const_defined?(name) ? ::Object.full_const_get(name) : ::Object.full_const_set(name, Class.new(::Object) )
      model.extend(extensions) unless model.ancestors.include?(extensions)
    end

  end # Events
end # DataMapper

DataMapper::Model.append_extensions DataMapper::Events
