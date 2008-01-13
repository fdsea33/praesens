class Relationship::EntityController < ApplicationController
  def index
#    list
    search
    render :action => 'search'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def search
    @entity_count = Entity.count
    if request.post?
      params[:search][:company_id] = @current_company_id
      params[:search][:clue] = '%'+params[:search][:clue].strip.tr(" ","%")+'%'
      @entity_pages, @entities = paginate :entities, :per_page => 30, :conditions => ["company_id=:company_id AND (surname ILIKE :clue OR first_name ILIKE :clue OR code ILIKE :clue)", params[:search]]
      render :action => 'list'
    end
  end


  def list
    @entity_pages, @entities = paginate :entities, :per_page => 10, :conditions => ["company_id=?",@current_company_id]
  end

  def show
    @entity = Entity.find(params[:id])
  end

  def new
    @entity = Entity.new
  end

  def create
    params[:entity][:company_id] = @current_company_id
    @entity = Entity.new(params[:entity])
    if @entity.save
#      flash[:notice] = 'Entity was successfully created.'
      redirect_to :action => 'show', :id=>@entity
    else
      render :action => 'new'
    end
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def update
    @entity = Entity.find(params[:id])
    if @entity.update_attributes(params[:entity])
      flash[:notice] = 'Entity was successfully updated.'
      redirect_to :action => 'show', :id => @entity
    else
      render :action => 'edit'
    end
  end

  def destroy
    Entity.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def entity_contact_new
    if request.post?
      @entity = session[:current_entity]
      params[:entity_contact][:company_id] = @current_company_id
      params[:entity_contact][:entity_id] = @entity.id
      @entity_contact = EntityContact.new(params[:entity_contact])
      if @entity_contact.save
        redirect_to :action => 'show', :id=>@entity
      end
    else
      @entity = Entity.find(params[:id])
      @entity_contact = @entity.contacts.new
      session[:current_entity] = @entity
    end
  end
  
end
