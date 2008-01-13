class Organisation::UserController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @user_pages, @users = paginate :users, :per_page => 30, :conditions => ["company_id=?",@current_company_id], :order=>:name
  end

  def show
    @user = User.find(params[:id])
  end

  def lock_access
    @user = User.find(params[:id])
    @user.locked = true
    @user.save!
    index
  end
  
  def unlock_access
    @user = User.find(params[:id])
    @user.locked = false
    @user.save!
    index
  end

  def new
    @user = User.new
  end

  def create
		params2 = params[:user]
		params2[:company_id] = @current_company.id
    @user = User.new(params2)
#    @user = User.new(params2[:user], :company_id=>@current_company.id)
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
