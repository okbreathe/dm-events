# dm-events

DataMapper plugin for modeling standalone and recurring events.

`dm-events` makes no assumptions about event relationships and the model only
provides temporal attributes (no name, place etc.).

## Usage

    # Create Normal Event
    @event = Event.new(:start => Time.now, :end => Time.now.midnight)

Recurrences are handled transparently by passing the `:every` (alias for `:frequency`) option. You can
additionally modify the recurrence by passing `:on` (The allowed number and the meaning of `:on` will 
change based on the frequency), or `:interval` (The number of intervals at an event's frequency 
in between occurrences of the event).

    # Event with Recurrence that will occur every other month on the first day or the month
    @event = Event.new(:start => now, :end => now.midnight, :every => :month, :interval => 2, :on => 1)

See dm-events/recurrence.rb for further details.

## Features

* Supports recurring events. 
  Recurring events are modeled using a linked approach. 
  When the event has occurred it becomes a concrete event. This allows
  easy and cheap reassigning of future events.

## Acknowledgements

Based on several ideas from both Chris Anderson's "[http://recurring.rubyforge.org/](Recurring)"
gem and Nando Vieira's "[http://github.com/fnando/recurrence](Recurrence)"

Schema based on: http://github.com/bakineggs/recurring_events_for

TODO

  * Finish the Docs
  * Implement limiting recurring events
  * Implement cancellations

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Asher Van Brunt. See LICENSE for details.
