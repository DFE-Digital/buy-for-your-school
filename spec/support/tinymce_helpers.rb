require "timeout"

module TinymceHelpers
  def fill_in_editor(label_text, with:)
    label = find("label", text: label_text)
    id = label[:for]

    Timeout.timeout(7, nil, "unable to find text editor with label #{label_text}") { sleep 1 until page.evaluate_script("tinymce.get('#{id}') !== null") }

    page.execute_script("tinymce.get('#{id}').setContent('#{with}')")
  end
end
