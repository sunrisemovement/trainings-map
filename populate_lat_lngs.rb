require 'json'
require_relative 'airtable'

map = {}

Training.all.each do |t|
  next unless t.upcoming?
  next if t['Latitude'] && t['Longitude']
  loc = "#{t['City']}, #{t['State']}"
  unless map.key?(loc)
    puts 'fetching'
    a = `curl https://api.mapbox.com/geocoding/v5/mapbox.places/#{URI.encode(loc)}.json?access_token=#{ENV['MAPBOX_API_KEY']}`
    lng, lat = JSON.parse(a)['features'][0]['center']
    map[loc] = [lat, lng]
  end
  puts loc, lat, lng
  lat, lng = map[loc]
  t['Latitude'] = lat
  t['Longitude'] = lng
  t.save
end
