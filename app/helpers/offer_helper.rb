module OfferHelper
  def offer_cta(offer)
    offer.call_to_action.presence || t("offers.show.cta", title: offer.title)
  end

  def show_offers_section?(number_of_offers)
    # Determines when to display the offers section.
    # The link is shown only when there are 1 or more offers
    number_of_offers.positive?
  end
end
