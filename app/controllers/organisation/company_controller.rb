class Organisation::CompanyController < ApplicationController
  def index
    @company = @current_company
  end

  def edit
    @company = Company.find_by_id @current_company_id
    if request.post?
      params[:company]
      if @company.update_attributes!(params[:company])
#        flash[:notice] = 'Company was successfully updated.'
        redirect_to :action => 'index', :id => @user
      else
        render :action => 'edit'
      end
    end
  end

end
