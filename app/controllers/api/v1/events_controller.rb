module API::V1
  class EventsController < ApplicationController
    
    def index
      if params[:product_ndc]
        @events = FdaEventService.search_product_ndc(params[:product_ndc].to_s) 
      elsif params[:brand_name] && params[:term]
        @events = FdaEventService.search_brand_term(params[:brand_name].to_s, params[:term].to_s) 
      else
        @error = { code: "INVALID_PARAMETERS", message: "You must supply a product_ndc or brand_name parameter." }   
      end
      @events = @events["results"]
      @error = { code: "NOT_FOUND", message: "No matches found!" } unless @events
      render template:'api/v1/shared/error' if @error
    end

  end
end