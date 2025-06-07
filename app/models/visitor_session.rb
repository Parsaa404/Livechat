class VisitorSession < ApplicationRecord
  belongs_to :visitor
  belongs_to :account
  has_many :visitor_events, dependent: :destroy

  validates :session_id, presence: true, uniqueness: { scope: :visitor_id }
  
  # Store session metadata
  store :metadata, accessors: [:referrer, :landing_page, :exit_page, :duration], coder: JSON
  
  # Store page views data
  store :page_views, accessors: [:total_pages, :pages], coder: JSON

  def self.create_or_update(visitor_id, session_id, attributes = {})
    session = find_or_initialize_by(visitor_id: visitor_id, session_id: session_id)
    session.update(attributes)
    session
  end

  def duration_in_seconds
    return 0 unless started_at && ended_at
    (ended_at - started_at).to_i
  end

  def add_page_view(page_data)
    self.pages ||= []
    self.pages << page_data
    self.total_pages = pages.size
    save
  end

  def is_active?
    ended_at.nil?
  end
end 