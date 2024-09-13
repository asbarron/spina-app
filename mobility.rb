# config/initializers/mobility.rb

require 'mobility'

Mobility.configure do
  plugins do
    backend :key_value, type: :text
    reader
    writer
    backend_reader
    active_record
    query
    cache
    fallbacks
    presence
    default
  end
end
