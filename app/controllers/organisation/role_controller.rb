class Organisation::RoleController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @role_pages, @roles = paginate :roles, :per_page => 30, :conditions => ["company_id=?",@current_company_id]
  end

  def show
    @role = Role.find(params[:id])
    @privileges = @role.recover_all_rights
  end

  def new
    @role = Role.new
  end

  def create
    params[:role][:company_id] = @current_company_id
    params[:role][:admin] = false
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
    if request.post?
      params[:role][:company_id] = @current_company_id
      params[:role][:admin] = false
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        redirect_to :action => 'show', :id => @role
      else
        render :action => 'edit'
      end
    end
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = 'Role was successfully updated.'
      redirect_to :action => 'show', :id => @role
    else
      render :action => 'edit'
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def manage_rights
    @role = Role.find(params[:id])
    if request.post?
      Right.update(params[:right].keys, params[:right].values)
      redirect_to :action => 'show', :id => @role
    end
    @role.recover_all_rights
  end

end
