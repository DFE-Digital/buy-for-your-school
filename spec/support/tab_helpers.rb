module TabHelpers
  def go_to_tab(tab_name)
    click_on tab_name

    sleep 0.01 until page.has_no_content?("Loading...")
  end
end
