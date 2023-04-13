class UserJourneyTracking
  def initialize(app, path_root, product_section, step_description_source: :request_path, path_root_strict: false)
    @app = app
    @path_root = path_root
    @product_section = product_section
    @step_description_source = step_description_source
    @path_root_strict = path_root_strict

    Rack::Request::Helpers.module_eval do
      def current_user_journey = UserJourney.find_by(id: session[:user_journey_id])
    end
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    begin
      @route_params = Rails.application.routes.recognize_path(env["PATH_INFO"])
    rescue ActionController::RoutingError
      @route_params = {}
    end

    track(request) if should_be_tracked?(request)

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

    # record any referral codes
    user_journey.update!(referral_campaign: request.params[:referral_campaign]) if request.params[:referral_campaign].present?

    # track step
    user_journey.record_step(product_section: @product_section, step_description: step_description(request))

    # store record id for further requests
    request.session[:user_journey_id] = user_journey.id
  end

  def should_be_tracked?(request) = !request.is_crawler? && request.method == "GET" && matching_path?(request.path)

  def matching_path?(path) = @path_root_strict ? path == @path_root : path.start_with?(@path_root)

  def step_description(request)
    case @step_description_source
    when :request_path then request.path
    else @step_description_source.call(request, @route_params)
    end
  end
end
