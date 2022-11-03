class UserJourneyTracking
  def initialize(app, path_root, product_section)
    @app = app
    @path_root = path_root
    @product_section = product_section

    Rack::Request::Helpers.module_eval do
      def current_user_journey = env["rack.user_journey"]
    end
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    # store record in request for controller access
    env["rack.user_journey"] = track(request) if should_be_tracked?(request)

    @app.call(env)
  end

  def track(request)
    user_journey = UserJourney.find_or_create_new_in_progress_by(
      if request.params[:session_id].present?
        { session_id: request.params[:session_id] }
      else
        { id: request.session[:user_journey_id] }
      end,
    )

    user_journey.tap do
      # record any referral codes
      user_journey.update!(referral_campaign: request.params[:referral_campaign]) if request.params[:referral_campaign].present?

      # track step
      user_journey.record_step(product_section: @product_section, step_description: request.path)

      # store record id for further requests
      request.session[:user_journey_id] = user_journey.id
    end
  end

  def should_be_tracked?(request) = !request.is_crawler? && request.path.start_with?(@path_root)
end
