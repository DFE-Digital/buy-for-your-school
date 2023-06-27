module CustomTurboStreamActions
  def redirect(url, frame_id)
    turbo_stream_action_tag(:redirect, url:, frame_id:)
  end
end
Turbo::Streams::TagBuilder.include(CustomTurboStreamActions)
