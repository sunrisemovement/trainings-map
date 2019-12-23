require 'airrecord'
require 'dotenv'
require 'pry'
require 'rb-readline'
require 'json'

Dotenv.load
Airrecord.api_key = ENV['AIRTABLE_API_KEY']

def date_parse(d)
  Date.parse(d).to_s
rescue
  nil
end

class Training < Airrecord::Table
  self.base_key = ENV['AIRTABLE_APP_KEY']
  self.table_name = 'Trainings'

  def upcoming?
    Date.parse(self['Start Date']) >= Date.today
  rescue
    false
  end

  def has_lat_lng?
    self['Latitude'] && self['Longitude']
  end

  def should_appear_on_map?
    return false unless upcoming?
    return false unless self['Verified?']
    return true if has_lat_lng?
    populate_lat_lng!
    has_lat_lng?
  end

  def computed_lat_lng
    loc = "#{self['City']}, #{self['State']}"
    a = `curl https://api.mapbox.com/geocoding/v5/mapbox.places/#{URI.encode(loc)}.json?access_token=#{ENV['MAPBOX_API_KEY']}`
    lng, lat = JSON.parse(a)['features'][0]['center']
    return lat, lng
  rescue
    return nil, nil
  end

  def populate_lat_lng!
    raise if has_lat_lng?
    return unless ENV['MAPBOX_API_KEY']
    lat, lng = computed_lat_lng
    return unless lat && lng
    self['Latitude'] = lat
    self['Longitude'] = lng
    save
  end

  def map_entry
    return {
      start_date: date_parse(self['Start Date']),
      end_date: date_parse(self['End Date']),
      city: self['City'],
      state: self['State'],
      type: self['Computed Training Name'],
      description: self['Training Description'],
      contact_email: self['Training Contact email'],
      registration_link: self['Training Registration link'],
      latitude: self['Latitude'],
      longitude: self['Longitude']
    }
  end

  def self.map_json
    all.select(&:should_appear_on_map?).map(&:map_entry).sort_by { |e| e[:start_date] }
  end
end
