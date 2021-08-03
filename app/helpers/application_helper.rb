# frozen_string_literal: true

# ApplicationHelper provides banner and footer tags.
module ApplicationHelper
  def banner_tag
    I18n.t("banner.beta.tag")
  end

  def banner_message
    I18n.t("banner.beta.message", support_email: ENV.fetch("SUPPORT_EMAIL"))
  end

  def footer_message
    I18n.t("banner.footer.message", support_email: ENV.fetch("SUPPORT_EMAIL"))
  end
end
