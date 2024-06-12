class MoveInteractionsFromCase3533To2850 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      interactions_to_move =
        %w[
          67d0a3fb-bd54-4a13-9338-eea27015d88b
          f4a68835-dfce-4e02-91b6-13c25920c2de
          afa7a64c-bc3a-4952-a75c-03d65f702705
          26054a1b-abab-46ce-a575-f1ddf31f9af5
          53bc9d56-d833-464b-b871-ff91a74e2500
          889f4477-db1d-4d23-96aa-9b01cd2a800f
          9c9c9a9d-f5dc-40fe-ac35-c7ad0d9a0590
          3e9afc7b-c361-4f7a-9cde-b596385a7a28
          fb9a48ac-b758-47cc-9185-cc8f397443a0
          44e345c1-83ce-4b19-8bd1-a1109a8ba1b7
          560878de-ab57-47b0-89cb-d84c3c4670e9
          36e6d6fe-f4d8-4212-b271-9c19628ebd0e
          b6a0a3d7-132f-44c7-bc71-be335501cee7
          8b9f3873-bf57-406c-b94b-785d3924e5ce
          b0415a5a-0035-466f-9a2c-11d73edbe2a4
          4d0165e2-0a5a-41f3-8cef-4622202e1fae
          7fa81a06-6e33-4173-a341-b5ac6033d97c
          07396f18-7806-4071-a1e7-1ef4c8df577c
          c6ca11a8-f374-4c7a-81e0-ab906caa22ff
          7a88759c-f4eb-4a9a-b241-9342a5614959
          bcf7d4e9-6d04-4464-ab0b-1bbed9946537
          23ae9941-d854-464a-aa0d-32c5cd702807
          8b2adde7-2ebd-4ea7-a9a9-aafd435b3d0e
          002b318a-a77c-4e64-9f27-3bc7111c45c0
          6c39cb10-1823-4cd4-8cb1-e64e0b028771
          66c0a55a-f5ad-417b-8e4b-92c1d774ed1e
          d4b6a232-c9fb-4a17-bb9c-97f28eb7031d
          d67a8eb6-6298-4c65-be7d-e91dcf1c12dc
          309e3f37-d079-484a-9a71-3a412d148435
          57479a5f-da95-4007-8bf2-6ff040a36609
        ]
      target_case = Support::Case.find_by(ref: "002850")
      return if target_case.nil?

      interactions_to_move.each do |interaction_id|
        interaction = Support::Interaction.find_by(id: interaction_id)
        next if interaction.nil? || interaction.case_id == target_case.id

        interaction.update!(case_id: target_case.id)
      end
    end
  end

  def down; end
end
