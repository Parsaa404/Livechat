class VisitorEvent < ApplicationRecord
  belongs_to :visitor
  belongs_to :visitor_session
  belongs_to :account

  validates :event_type, presence: true
  validates :event_name, presence: true

  # Store event data
  store :event_data, accessors: [:properties, :value], coder: JSON

  EVENT_TYPES = %w[page_view trigger custom].freeze

  def self.create_event(visitor_id, session_id, event_type, event_name, data = {})
    visitor = Visitor.find_by(id: visitor_id)
    session = VisitorSession.find_by(id: session_id)
    
    return nil unless visitor && session

    create!(
      visitor_id: visitor_id,
      visitor_session_id: session_id,
      account_id: visitor.account_id,
      event_type: event_type,
      event_name: event_name,
      event_data: data
    )
  end

  def self.trigger_events
    where(event_type: 'trigger')
  end

  def self.page_views
    where(event_type: 'page_view')
  end

  def self.custom_events
    where(event_type: 'custom')
  end
end 