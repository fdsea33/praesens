class Relationship::SettingsController < ApplicationController
  def index
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :nature_destroy ],
         :redirect_to => { :action => :index }

  def nature_list
    @entity_nature_pages, @entity_natures = paginate :entity_natures, :per_page => 10, :conditions => ["company_id=?",@current_company_id], :order=>:name
  end

  def nature_new
    if request.post? 
      params[:entity_nature][:company_id] = @current_company_id
      @entity_nature = EntityNature.new(params[:entity_nature])
      if @entity_nature.save
        flash[:notice] = 'EntityNature was successfully created.'
        redirect_to :action => 'nature_list'
#      else
#        render :action => 'new'
      end
    else
      @entity_nature = EntityNature.new
    end
  end

  def nature_edit
    @entity_nature = EntityNature.find(params[:id])
    if request.post?
      if @entity_nature.update_attributes(params[:entity_nature])
        flash[:notice] = 'EntityNature was successfully updated.'
        redirect_to :action => 'nature_list', :id => @entity_nature
#      else
#        render :action => 'edit'
      end
    end
  end

  def nature_destroy
    EntityNature.find(params[:id]).destroy
    redirect_to :action => 'nature_list'
  end


# ContactNorm

  def contact_norm_list
    @entity_contact_norm_pages, @entity_contact_norms = paginate :entity_contact_norms, :per_page => 10, :conditions => ["company_id=?",@current_company_id], :order=>:name
  end

  def contact_norm_new
    if request.post? 
      params[:entity_contact_norm][:company_id] = @current_company_id
      @entity_contact_norm = EntityContactNorm.new(params[:entity_contact_norm])
      if @entity_contact_norm.save
        flash[:notice] = 'EntityContactNorm was successfully created.'
        redirect_to :action => 'contact_norm_list'
#      else
#        render :action => 'new'
      end
    else
      @entity_contact_norm = EntityContactNorm.new
    end
  end

  def contact_norm_edit
    @entity_contact_norm = EntityContactNorm.find(params[:id])
    if request.post?
      if @entity_contact_norm.update_attributes(params[:entity_contact_norm])
        flash[:notice] = 'EntityContactNorm was successfully updated.'
        redirect_to :action => 'contact_norm_list', :id => @entity_contact_norm
#      else
#        render :action => 'edit'
      end
    end
  end

  def contact_norm_destroy
    EntityContactNorm.find(params[:id]).destroy
    redirect_to :action => 'contact_norm_list'
  end

  def contact_norm_manage_items
    @entity_contact_norm = EntityContactNorm.find(params[:id])
    @entity_contact_norm_item = @entity_contact_norm.items.new
    session[:entity_contact_norm_id] = EntityContactNorm.find(params[:id])
  end

  def contact_norm_add_item
    @entity_contact_norm = EntityContactNorm.find(session[:entity_contact_norm_id])
    if request.post?
      params[:entity_contact_norm_item][:company_id] = @current_company_id
      params[:entity_contact_norm_item][:entity_contact_norm_id] = @entity_contact_norm.id
      @entity_contact_norm_item = EntityContactNormItem.new(params[:entity_contact_norm_item])
      if @entity_contact_norm_item.save
        @entity_contact_norm_item = @entity_contact_norm.items.new
      end
    end
    render :action => 'contact_norm_manage_items', :id=>@entity_contact_norm.id unless request.xhr?
#    redirect_to :action => 'contact_norm_manage_items', :id=>@entity_contact_norm.id, :object=>@entity_contact_norm_item
  end

  def contact_norm_item_push_up
    entity_contact_norm_item = EntityContactNormItem.find(params[:id])
    @entity_contact_norm = entity_contact_norm_item.entity_contact_norm
    @entity_contact_norm_item = @entity_contact_norm.items.new
    entity_contact_norm_item.move_higher
    render :action => 'contact_norm_manage_items', :id=>@entity_contact_norm.id
  end
  
  def contact_norm_item_push_down
    entity_contact_norm_item = EntityContactNormItem.find(params[:id])
    @entity_contact_norm = entity_contact_norm_item.entity_contact_norm
    @entity_contact_norm_item = @entity_contact_norm.items.new
    entity_contact_norm_item.move_lower
    render :action => 'contact_norm_manage_items', :id=>@entity_contact_norm.id
  end

  def contact_norm_item_destroy
    entity_contact_norm_item = EntityContactNormItem.find(params[:id])
    @entity_contact_norm = entity_contact_norm_item.entity_contact_norm
    @entity_contact_norm_item = @entity_contact_norm.items.new
    entity_contact_norm_item.destroy
    render :action => 'contact_norm_manage_items', :id=>@entity_contact_norm.id
  end


# ContactType

  def contact_type_list
    @entity_contact_type_pages, @entity_contact_types = paginate :entity_contact_types, :per_page => 10, :conditions => ["company_id=?",@current_company_id], :order=>:name
  end

  def contact_type_new
    if request.post? 
      params[:entity_contact_type][:company_id] = @current_company_id
      @entity_contact_type = EntityContactType.new(params[:entity_contact_type])
      if @entity_contact_type.save
        flash[:notice] = 'EntityContactType was successfully created.'
        redirect_to :action => 'contact_type_list'
#      else
#        render :action => 'new'
      end
    else
      @entity_contact_type = EntityContactType.new
    end
  end

  def contact_type_edit
    @entity_contact_type = EntityContactType.find(params[:id])
    if request.post?
      if @entity_contact_type.update_attributes(params[:entity_contact_type])
        flash[:notice] = 'EntityContactType was successfully updated.'
        redirect_to :action => 'contact_type_list', :id => @entity_contact_type
#      else
#        render :action => 'edit'
      end
    end
  end

  def contact_type_destroy
    EntityContactType.find(params[:id]).destroy
    redirect_to :action => 'contact_type_list'
  end




end
