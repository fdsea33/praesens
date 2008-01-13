# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_praesens_session_id'
	before_filter :authorize, :except=> :login
	@user_logged = false
	
#  ActiveScaffold.set_defaults do |config| 
#    config.ignore_columns.add [:created_at, :created_by, :updated_at, :updated_by, :lock_version]
#    config.show.link.label="Show".t
#    config.show.link.action = "show"
#    config.show.link.inline = false
#    config.update.link.label="Edit".t
#    config.delete.link.label="Destroy".t
#  end

	def authorize_action?(action_name)
	  User.current_user.role.authorize_action?(action_name, self.class.controller_path)
	end
	
	def authorize_procedure?(procedure_name)
	  User.current_user.role.authorize_procedure?(procedure_name, self.class.controller_path)
	end
	
	private

	def authorize
	  user = User.find_by_id(session[:user_id])
    User.current_user = user unless session[:user_id].nil?
#    User.current_user = User.find(session[:user_id]) unless session[:user_id].nil?
		unless user
			session[:original_uri] = request.request_uri
			flash.now[:notice] = "authorization:please_login".t
			redirect_to :controller=>"/public/authentication", :action=>"login"
			@user_logged = false
		else
		  unless @user_logged
  			@current_user = user
	  		@current_company = @current_user.company
	  		@current_company_id = @current_company.id
  			@banner_parts = @current_user.parts
        @user_logged = true
      end
      part = self.class.controller_path.split("/")[0]
      @part = nil;
      @component = nil;
      @action_path = "/"+self.class.controller_path+"#"+action_name
      @title = action_name.to_s.humanize.t if @title.nil?
      @home_class = "part-link"
      @home_class += " active_part" if part=="public" and action_name=="index"

      if authorize_action? action_name
        @part = Part.find_by_name(part)
        @action_path = @part.title if @part
        if @part
          @component = PartComponent.find_by_name_and_part_id(self.class.controller_name, @part.id)
          @action_path += " &raquo; "+@component.title+" &raquo; "+action_name.humanize if @component
        end
      else      
   		  flash.now[:notice] = "authorization:page_not_authorized".t  action_name
        request.env["HTTP_REFERER" ] ? (redirect_to :back) : (redirect_to  :controller=>"/public/home")
        return false
      end

		end
	end
end
