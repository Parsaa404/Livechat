class Visitor < ApplicationRecord
  belongs_to :account
  has_many :visitor_sessions, dependent: :destroy
  has_many :visitor_events, dependent: :destroy

  validates :visitor_id, presence: true, uniqueness: { scope: :account_id }
  
  # Store visitor's location data
  store :location_data, accessors: [:country, :city, :region, :latitude, :longitude], coder: JSON
  
  # Store visitor's device and browser info
  store :device_data, accessors: [:browser, :os, :device_type, :screen_resolution], coder: JSON
  
  # Store UTM parameters
  store :utm_data, accessors: [:source, :medium, :campaign, :term, :content], coder: JSON

  def self.create_or_update(account_id, visitor_id, attributes = {})
    visitor = find_or_initialize_by(account_id: account_id, visitor_id: visitor_id)
    visitor.update(attributes)
    visitor
  end

  def last_session
    visitor_sessions.order(created_at: :desc).first
  end

  def total_sessions
    visitor_sessions.count
  end

  def total_events
    visitor_events.count
  end

  def total_triggers
    visitor_events.where(event_type: 'trigger').count
  end
end 