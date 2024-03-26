class SeedLocalAuthorities < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      direction.up do
        Support::Organisation.find_each do |organisation|
          local_authority = LocalAuthority.find_or_initialize_by(la_code: organisation.local_authority_legacy["code"]) do |la|
            la.name = organisation.local_authority_legacy["name"]
            la.save!
          end

          organisation.update!(local_authority:)
        end
      end

      direction.down do
        Support::Organisation.update_all(local_authority: nil)
        LocalAuthority.destroy_all
      end
    end
  end
end
