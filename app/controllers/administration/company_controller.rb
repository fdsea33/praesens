class Administration::CompanyController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @company_pages, @companies = paginate :companies, :per_page => 10
  end

  def show
    @company = Company.find(params[:id])
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
      login = @company.default_login
      flash[:notice] = "La société #{@company.name} a été correctement. L'administrateur de la société est <em>"+login[:name]+"</em> avec <em>"+login[:password]+"</em> pour mot de passe."
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:notice] = 'Company was successfully updated.'
      redirect_to :action => 'show', :id => @company
    else
      render :action => 'edit'
    end
  end

  def destroy
    Company.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
