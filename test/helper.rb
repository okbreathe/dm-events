require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dm-events'

class Object

  def shout(*msgs)
    wrap = "\n" + "="*80 + "\n"
    msg  = wrap + "#{msgs.collect{|m| m.inspect}.join("\n")}" + wrap
    $stdout.puts "[1;35m%s[0m" % msg
  end

end

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def now
    @now = Time.utc(2010,6,1)
  end
end
