class CreatePages < ActiveRecord::Migration[6.1]
  def up
    create_table :pages, id: :uuid do |t|
      t.string :title
      t.text :body
      t.string :slug

      t.timestamps
    end
    populate
  end

  def down
    drop_table :pages
  end

private

  def populate
    Page.create(
      title: "Accessibility",
      body: "<!-----\nNEW: Check the \"Suppress top comment\" option to remove this info from the output.\n\nConversion time: 0.584 seconds.\n\n\nUsing this Markdown file:\n\n1. Paste this output into your source file.\n2. See the notes and action items below regarding this conversion run.\n3. Check the rendered output (headings, lists, code blocks, tables) for proper\n   formatting and use a linkchecker before you publish this page.\n\nConversion notes:\n\n* Docs to Markdown version 1.0β31\n* Thu Oct 28 2021 02:53:52 GMT-0700 (PDT)\n* Source doc: GHBS Accessibility statement\n----->\n\n\n\n# **Accessibility statement**\n\n\n## **How accessible this website is**\n\nGet help buying for schools is a new service run by the Department for Education. We’re trialling it with a limited number of users at the moment.\n\nWe have taken steps to make this service accessible:\n\n\n\n* we designed it using the [GOV.UK accessible design principles](https://design-system.service.gov.uk/accessibility/)\n* we did an audit to see if there were any accessibility issues\n* we tested the design with users with accessibility needs\n\n\n## **What to do if you cannot access parts of this website**\n\nIf you need information on this website in a different format, such as accessible PDF, large print, easy read, audio recording or braille, please email us on schools.digital@education.gov.uk.\n\nWe’ll consider your request and respond to you within 5 working days.\n\n[AbilityNet](https://mcmw.abilitynet.org.uk/) also has advice on making your device easier to use if you’re disabled.\n\n\n## **Reporting accessibility problems with this website**\n\nIf you have any problems accessing the service or want to give us feedback, please email us on schools.digital@education.gov.uk\n\n\n## **Enforcement procedure**\n\nThe Equality and Human Rights Commission (EHRC) is responsible for enforcing the Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018 (the ‘accessibility regulations’).\n\nIf you’re not happy with how we respond to your complaint, please [contact the quality Advisory and Support Service (EASS)](https://www.equalityadvisoryservice.com/).\n\n\n## **Technical information about this website’s accessibility**\n\nThe Department for Education is committed to making its website services accessible, in accordance with the Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018.\n\nThis website is compliant with the [Web Content Accessibility Guidelines version 2.1](https://www.w3.org/TR/WCAG21) AA standard.\n\n\n## **What we’re doing to improve accessibility**\n\nWe’ll continue to test the accessibility of this service as it develops.\n",
      slug: "accessibility",
      updated_at: Date.new(2021, 7, 7),
    )
  end
end
