class Organisation::EmployeeController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @company_employee_pages, @company_employees = paginate :company_employees, :per_page => 10, :conditions => ["company_id=?",@current_company_id]
  end

  def show
    @company_employee = CompanyEmployee.find(params[:id])
  end

  def new
    @company_employee = CompanyEmployee.new
  end

  def create
    params[:company_employee][:company_id] = @current_company_id
    @company_employee = CompanyEmployee.new(params[:company_employee])
    if @company_employee.save
      flash[:notice] = 'CompanyEmployee was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @company_employee = CompanyEmployee.find(params[:id])
  end

  def update
    @company_employee = CompanyEmployee.find(params[:id])
    if @company_employee.update_attributes(params[:company_employee])
      flash[:notice] = 'CompanyEmployee was successfully updated.'
      redirect_to :action => 'show', :id => @company_employee
    else
      render :action => 'edit'
    end
  end

  def destroy
    CompanyEmployee.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
