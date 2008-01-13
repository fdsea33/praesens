class Public::AuthenticationController < ApplicationController
  def index
		redirect_to :action=>:login
  end

	def login
		session[:user_id] = nil
		if request.post?
			user = User.authenticate(params[:name], params[:password])
			if user
				ArkanisDevelopment::SimpleLocalization::Language.use user.language.code
				session[:user_id] = user.id
				redirect_to :controller =>"home"
			else
				flash.now[:notice] = "authorization:invalid_password".t
			end
		end
	end

  def logout
		session[:user_id] = nil
		flash.now[:notice] = "authorization:disconnected".t
		redirect_to(:action=>"login")
  end
end
