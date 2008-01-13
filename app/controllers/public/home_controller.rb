class Public::HomeController < ApplicationController
  def index
	  @title = "Welcome".t
  end

	def of
		@part = Part.find_by_name(params[:part])
		if @part.nil?
		  flash[:notice] = "authorization:invalid_url".t params[:part]
			redirect_to :action=>:index
		end
	  @title = @part.title
	end

end
