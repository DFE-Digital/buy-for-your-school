module Support
  class SchoolsController < ApplicationController
    def show
      @org = Organisation.find_by(urn: params[:id])
    end
  end
end
