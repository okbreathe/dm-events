class Pig
  include DataMapper::Resource
  property :id,     Serial
  property :name,   String
end

class Event
  include DataMapper::Resource
  has_events
end

class PolymorphicEvent
  include DataMapper::Resource
  has_events :polymorphic => true
end

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate! if defined?(DataMapper)
