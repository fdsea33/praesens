class Organisation::DepartmentController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @company_department_pages, @company_departments = paginate :company_departments, :per_page => 20, :conditions => ["company_id=?",@current_company_id]
  end

  def show
    @company_department = CompanyDepartment.find(params[:id])
  end

  def new
    @company_department = CompanyDepartment.new
  end

  def create
    params[:company_department][:company_id] = @current_company_id
    @company_department = CompanyDepartment.new(params[:company_department])
    if @company_department.save
      flash[:notice] = 'CompanyDepartment was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @company_department = CompanyDepartment.find(params[:id])
  end

  def update
    @company_department = CompanyDepartment.find(params[:id])
    if @company_department.update_attributes(params[:company_department])
      flash[:notice] = 'CompanyDepartment was successfully updated.'
      redirect_to :action => 'show', :id => @company_department
    else
      render :action => 'edit'
    end
  end

  def destroy
    CompanyDepartment.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
