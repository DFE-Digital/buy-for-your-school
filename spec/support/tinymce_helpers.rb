module TinymceHelpers
  def fill_in_editor(label_text, with:)
    label = find("label", text: label_text)
    id = label[:for]

    sleep 0.5 until page.evaluate_script("tinymce.get('#{id}') !== null")

    page.execute_script("tinymce.get('#{id}').setContent('#{with}')")
  end
end
