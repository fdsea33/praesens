class Organisation::AccessProfileController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def add_privilege
  end

  def remove_privilege
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @access_profile_pages, @access_profiles = paginate :access_profiles, :per_page => 30, :conditions => ["company_id=?",session[:company_id]]
  end

  def show
    @access_profile = AccessProfile.find(params[:id])
  end

  def new
    @access_profile = AccessProfile.new
  end

  def create
    params[:access_profile][:company_id] = @current_company.id
    @access_profile = AccessProfile.new(params[:access_profile])
    if @access_profile.save
      flash[:notice] = 'AccessProfile was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @access_profile = AccessProfile.find(params[:id])
  end

  def update
    @access_profile = AccessProfile.find(params[:id])
    if @access_profile.update_attributes(params[:access_profile])
      flash[:notice] = 'AccessProfile was successfully updated.'
      redirect_to :action => 'show', :id => @access_profile
    else
      render :action => 'edit'
    end
  end

  def destroy
    AccessProfile.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def manage_privileges
    @privileges = AccessProfile.find(params[:id]).privileges
  end

end
