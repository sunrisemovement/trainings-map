require 'airrecord'
require 'dotenv'
require 'pry'
require 'rb-readline'

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

  def should_appear_on_map?
    upcoming? && self['Verified?'] && self['Latitude'] && self['Longitude']
  end

  def training_type
    if self['Type of Training'] == 'other'
      self['If you do not see your workshop listed above, please write here']
    else
      self['Type of Training']
    end
  end

  def map_entry
    return {
      start_date: date_parse(self['Start Date']),
      end_date: date_parse(self['End Date']),
      city: self['City'],
      state: self['State'],
      type: self['Computed Training Name'],
      description: self['Training Description'],
      contact_email: self['Training Contact email'] || self['Lead Trainer Email'],
      registration_link: self['Training Registration link'],
      latitude: self['Latitude'],
      longitude: self['Longitude']
    }
  end

  def self.map_json
    all.select(&:should_appear_on_map?).map(&:map_entry).sort_by { |e| e[:start_date] }
  end
end
