class Administration::ApplicationController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @part_pages, @parts = paginate :parts, :per_page => 10
  end

  def show
    @part = Part.find(params[:id])
  end

  def new
    @part = Part.new
  end

  def create
    @part = Part.new(params[:part])
    if @part.save
      flash[:notice] = 'Part was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @part = Part.find(params[:id])
  end

  def update
    @part = Part.find(params[:id])
    if @part.update_attributes(params[:part])
      flash[:notice] = 'Part was successfully updated.'
      redirect_to :action => 'show', :id => @part
    else
      render :action => 'edit'
    end
  end

  def destroy
    Part.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
