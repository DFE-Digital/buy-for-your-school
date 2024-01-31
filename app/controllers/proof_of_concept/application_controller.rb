class ProofOfConcept::ApplicationController < ApplicationController
  include SupportAgents

private

  def authorize_agent_scope = :access_proof_of_concepts?
end
