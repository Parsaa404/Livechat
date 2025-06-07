module Api
  module V1
    class VisitorTrackingController < Api::V1::BaseController
      before_action :set_account
      before_action :set_visitor_tracking_service

      def track
        visitor = @visitor_tracking_service.track_visitor(visitor_params)
        render json: { success: true, visitor_id: visitor.id }
      end

      def end_session
        @visitor_tracking_service.end_session(params[:visitor_id], params[:session_id])
        render json: { success: true }
      end

      def track_event
        @visitor_tracking_service.track_event(
          params[:visitor_id],
          params[:session_id],
          params[:event_type],
          event_params
        )
        render json: { success: true }
      end

      def stats
        time_range = params[:time_range].to_i.hours || 24.hours
        stats = @visitor_tracking_service.get_visitor_stats(time_range)
        render json: stats
      end

      private

      def set_account
        @account = Current.account
      end

      def set_visitor_tracking_service
        @visitor_tracking_service = VisitorTrackingService.new(@account)
      end

      def visitor_params
        params.require(:visitor).permit(
          :visitor_id,
          :session_id,
          location: [:country, :city, :region, :latitude, :longitude],
          device: [:browser, :os, :device_type, :screen_resolution],
          utm: [:source, :medium, :campaign, :term, :content],
          session_data: [:referrer, :landing_page],
          page_data: [:name, :url, :title]
        )
      end

      def event_params
        params.require(:event).permit(:name, properties: {}, value: {})
      end
    end
  end
end 