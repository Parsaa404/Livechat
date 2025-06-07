class VisitorTrackingService
  def initialize(account)
    @account = account
  end

  def track_visitor(visitor_data)
    visitor = Visitor.create_or_update(
      @account.id,
      visitor_data[:visitor_id],
      {
        location_data: visitor_data[:location],
        device_data: visitor_data[:device],
        utm_data: visitor_data[:utm]
      }
    )

    track_session(visitor, visitor_data[:session_id], visitor_data[:session_data])
    track_event(visitor, visitor_data[:session_id], 'page_view', visitor_data[:page_data])
    
    visitor
  end

  def track_session(visitor, session_id, session_data)
    VisitorSession.create_or_update(
      visitor.id,
      session_id,
      {
        account_id: @account.id,
        started_at: Time.current,
        metadata: {
          referrer: session_data[:referrer],
          landing_page: session_data[:landing_page]
        }
      }
    )
  end

  def track_event(visitor, session_id, event_type, event_data)
    session = VisitorSession.find_by(visitor_id: visitor.id, session_id: session_id)
    return unless session

    VisitorEvent.create_event(
      visitor.id,
      session.id,
      event_type,
      event_data[:name],
      event_data
    )
  end

  def end_session(visitor_id, session_id)
    session = VisitorSession.find_by(visitor_id: visitor_id, session_id: session_id)
    return unless session

    session.update(
      ended_at: Time.current,
      metadata: session.metadata.merge(
        exit_page: session.pages&.last,
        duration: session.duration_in_seconds
      )
    )
  end

  # Analytics Methods
  def get_visitor_stats(time_range = 24.hours)
    {
      total_visitors: get_total_visitors(time_range),
      total_sessions: get_total_sessions(time_range),
      total_triggers: get_total_triggers(time_range),
      visitors_by_country: get_visitors_by_country(time_range),
      daily_visits: get_daily_visits(time_range),
      active_sessions: get_active_sessions
    }
  end

  private

  def get_total_visitors(time_range)
    Visitor.where(account_id: @account.id)
           .where('created_at >= ?', Time.current - time_range)
           .count
  end

  def get_total_sessions(time_range)
    VisitorSession.where(account_id: @account.id)
                 .where('created_at >= ?', Time.current - time_range)
                 .count
  end

  def get_total_triggers(time_range)
    VisitorEvent.where(account_id: @account.id)
                .where(event_type: 'trigger')
                .where('created_at >= ?', Time.current - time_range)
                .count
  end

  def get_visitors_by_country(time_range)
    Visitor.where(account_id: @account.id)
           .where('created_at >= ?', Time.current - time_range)
           .group("location_data->>'country'")
           .count
  end

  def get_daily_visits(time_range)
    VisitorSession.where(account_id: @account.id)
                 .where('created_at >= ?', Time.current - time_range)
                 .group("DATE(created_at)")
                 .count
  end

  def get_active_sessions
    VisitorSession.where(account_id: @account.id)
                 .where(ended_at: nil)
                 .count
  end
end 