class UpdateSlugsAndContentfulIdsInPages < ActiveRecord::Migration[6.1]
  # Add contenful ids defined in contentful, as well as update our slugs to match
  # what we have in contentful.
  def up
    [
      %w[accessibility accessibility G2AeR8ZCU4nqwuuDdJO1k],
      %w[next_steps_mfd next-steps-mfd 4a070fp6xrWB0yv1GMC5vQ],
      %w[privacy_notice privacy 1j8HoHjNNuqIAPjBVWedVe],
      %w[next_steps_catering next-steps-catering 4nOVXkLTCZMlaTxMCXQnCa],
      %w[terms_and_conditions terms-and-conditions 4jW1v1202HOoZoJr19lfpa],
    ].each do |old_slug, new_slug, contentful_id|
      Page.find_by(slug: old_slug)
         &.update!(contentful_id:, slug: new_slug)
    end

    # Once all pages have the correct slug and coresponding contentful id
    # we can safely add a unique constraint to the field.
    add_index :pages, :contentful_id, unique: true
  end

  def down
    remove_index :pages, :contentful_id, unique: true
  end
end
