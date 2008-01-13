# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Example : <%= text_box CompanyEmployee", "title" %>
  def text_box(model,attribute,options={:cols=>80,:rows=>8, :position=>nil, :type=>nil, :label=>nil, :required_on=>false, :limit=>255, :indicator=>true, :allow_nil=>true})
    input = ""
    label = ""
    style_class = ""
    input_type  = options[:type]
    input_limit = options[:limit] || 255
    model = model.to_s.camelize.constantize if model.is_a? Symbol
    attribute = attribute.to_s
    reflection = model.reflections[attribute.to_sym]
#    reflection = model.foreign_keys.detect {|c| c[:column_names].size==1 and c[:column_names][0]==attribute}
    input_type = :select unless reflection.nil?
    attribute = reflection.options[:foreign_key] if input_type==:select
    if options[:label].nil? and (input_type.nil? or input_type==:select)
      column = model.columns_hash[attribute]
      style_class = "required" if column.required_on
      label = label_box(model, attribute)
      if input_type!=:select
        if column.text? && column.limit && column.limit<128
          input_type = :string
          input_limit = column.limit
        elsif column.text? && column.limit && column.limit>=128
          input_type = :text
        elsif column.type == :boolean
          input_type = :boolean
        elsif column.type == :date
          input_type = :date
        elsif column.number?
          input_type = :number
        else
          input_type = :textarea
        end
      end
    elsif not options[:label].nil? and not options[:type].nil?
      style_class = "required" if options[:required_on]
      label = label_box_tag(model,attribute,options[:label],options[:required_on])
      input_type=:text if [:string].include? input_type and input_limit>=128
    else
      raise Exception.new("Undefined text_box")
    end

    
    references = nil
    references_name = nil
    completion_options = {}
    completion_options[:indicator] = "loader"
    if input_type == :select
      references = reflection.name # reflection.references_table_name.singularize.to_sym
      references_name = options[:select_label].to_sym
#      completion_options[:indicator] = nil unless options[:indicator]
    end
    input_limit = 64 if input_type==:password and input_limit > 64
    model_name = model.class_name.underscore
    case input_type
      when :string   : input = text_field model_name, attribute, :size=>input_limit+2, :maxlength=>input_limit, :class=>style_class
      when :password : input = password_field  model_name, attribute, :size=>input_limit+2, :maxlength=>input_limit, :class=>style_class
      when :text     : input = text_field model_name, attribute, {:style=>"width:100%", :class=>style_class}
      when :boolean  : input = check_box model_name, attribute , {}, "true", "false"
#      when :date    : input = date_select(model_name, attribute, :order => [:day, :month, :year])
      when :date     : input = text_field model_name, attribute, :maxlength=>16, :class=>style_class
      when :number   : input = text_field model_name, attribute, :maxlength=>32, :class=>style_class
      when :select   : input = belongs_to_auto_completer model_name.to_sym, references, references_name, { :allow_nil=>options[:allow_nil]}, {:style=>"width:100%;", :class=>style_class }, {:skip_style=>true,:indicator=>"loader"}
      else input = text_area model_name, attribute, :cols=>options[:cols], :rows=>options[:rows]-1, :style=>"width:100%;", :class=>style_class
    end
    if options[:position].nil?
      options[:position] = input_type==:textarea ? :bottom : :right
    end
    field_box(label,input,options[:position])
  end


  def read_box(record, attribute, options={:position=>nil, :type=>nil, :label=>nil, :through=>nil, :action=>:show, :controller=>nil})
    output = ""
    label = ""
    style_class = ""
    output_type  = options[:type]
#    model = model.to_s.camelize.constantize if model.is_a? Symbol
    record = instance_variable_get("@#{record.to_s}") if record.is_a? Symbol
    record = record.send(options[:through]) unless options[:through].nil?
    model = record.class
    attribute = attribute.to_s
    if options[:label].nil? and output_type.nil?
      column = model.columns_hash[attribute]
      label = label_box(model,attribute,"read")
      if column.text? && column.limit && column.limit<128
        output_type = :string
      elsif column.type == :boolean
        output_type = :boolean
      elsif column.type == :date
        output_type = :date
      elsif column.number?
        output_type = :number
      else
        output_type = :text
      end
    elsif not options[:label].nil? and not options[:type].nil?
      label = label_box_tag(model,attribute,options[:label],false,"read")
    else
      raise Exception.new("Undefined read_box")
    end

    value = nil
    value = record.send(attribute) if record
    if options[:through] and output_type!=:boolean
      options[:action] = :show if options[:action].nil?
      controller = self.controller.controller_path
      controller = options[:controller] unless options[:controller].nil?
      value = link_to value, {:controller=>"/"+controller, :action=>options[:action], :id=>record.id}
    end
    case output_type
      when :string   : output = content_tag(:div, value, {:style=>"width:100%", :class=>style_class})
      when :boolean  : output = check_box_tag attribute, "1", value, {:disabled=>"true"}
      when :date     : output = content_tag(:div, value, {:style=>"width:100%, text-align: center;", :class=>style_class})
      when :number   : output = content_tag(:div, value, {:style=>"width:100%, text-align: right;", :class=>style_class})
      else output = content_tag(:div, value, {:style=>"width:100%", :class=>style_class})
    end
    options[:position] = (output_type==:textarea ? :bottom : :right) if options[:position].nil?
    field_box(label,output,options[:position], "read")
  end



  def password_box(model,attribute,options={:position=>:right, :human_name=>nil})
    input = password_field  model.class_name.underscore, attribute
    if options[:human_name].nil?
      label = label_box(model, attribute)
    else
      label = label_box_tag(model, attribute, options)
    end
    field_box(label,input,options[:position])
  end



  def select_box(model,attribute,list,options={:include_blank=>false,:position=>:right})
    column = model.columns_hash[attribute]
    if column 
      label = label_box(model,attribute)
    else
      label = label_box_tag(model, attribute, (options[:label] || attribute).t, options[:required_on])
    end
    input = select(model.class_name.underscore, attribute, list.nil? ? [] : list, options)
    field_box(label,input, options[:position])
  end
  
  
  def action_columns_header(nb_columns=3)
    "<th class=\"action\" colspan=\"#{nb_columns}\">Actions</th>"
  end
 
  def action_columns(object, operations=[:show, :edit, :destroy])
    code = ""
    operations.each do |operation|
      code += "<td class=\"action\">"
      case operation
        when :none    : code += ""
        when :default : code += operation(object, {:action=>:show})+"</td><td class=\"action\">"+operation(object, {:action=>:edit})+"</td><td class=\"action\">"+operation(object, {:action=>:destroy, :method=>:post, :confirm=>'Are you sure?'})
        when :show    : code += operation(object, {:action=>:show})
        when :edit    : code += operation(object, {:action=>:edit})
        when :destroy : code += operation(object, {:action=>:destroy, :method=>:post, :confirm=>'Are you sure?'})
        else
          if operation.class == Symbol
            code += operation(object, {:action=>operation})
          else
            code += operation(object, operation)
          end
      end
      code += "</td>"
    end
    code
  end
  
  def auth(procedure_name, controller_path=nil)
    self.controller.authorize_procedure? procedure_name.to_s
  end  

  def autha(action_name, controller_path=nil)
    self.controller.authorize_action? action_name
  end  

  def procedure_title(procedure_name)
    proc = Procedure.find_by_name_and_controller_path procedure_name, self.controller.controller_path
    self.controller.authorize_procedure? procedure_name
  end  

  def operation(object, operation, controller_path=self.controller.controller_path)
    return "" if not operation[:condition].nil? and operation[:condition]==false
    code = ""
    operation[:action] = operation[:actions][object.send(operation[:use]).to_s] if operation[:use]
    if User.current_user.role.authorize_action?(operation[:action].to_s, controller_path)
      parameters = {}
      parameters[:confirm] = operation[:confirm].t unless operation[:confirm].nil?
      parameters[:method]  = operation[:method]    unless operation[:method].nil?
      parameters[:id]      = operation[:action].to_s+"-"+(object.nil? ? 0 : object.id).to_s
    
      image_title = operation[:title].nil? ? operation[:action].to_s.humanize.t : operation[:title].t
      dir = "#{RAILS_ROOT}/public/images/"
      image_file = "buttons/"+(operation[:image].nil? ? operation[:action].to_s.gsub(operation[:prefix].to_s||"","") : operation[:image].to_s)+".png"
      image_file = "buttons/unknown.png" unless File.file? dir+image_file
      code += link_to image_tag(image_file, :border => 0, :alt=>image_title, :title=>image_title), {:action => operation[:action].to_s, :id => object.id}, parameters
    end
    code
  end

  def value_image(value)
    unless value.nil?
      image = nil
      case value.to_s
        when "true" : image = "true"
        when "false" : image = nil
        else image =  value.to_s
      end
#      "<div align=\"center\">"+image_tag("buttons/"+image+".png", :border => 0, :alt=>image.t, :title=>image.t)+"</div>" unless image.nil?
      image_tag("buttons/"+image+".png", :border => 0, :alt=>image.t, :title=>image.t) unless image.nil?
    end
  end


  
  def print_table (table, records=nil, &block)
    records = instance_variable_get("@#{table.to_s}") if records.nil?
    record_pages = instance_variable_get("@#{table.to_s.singularize.to_s}_pages") if record_pages.nil?
    model  = table.to_s.singularize.camelize.constantize
    definition = OutputTableDefinition.new(model)
    yield definition
    code = ''
    if records and records.size>0
      line = ''
      for column in definition.columns
        case column.nature
          when :datum  : line += content_tag('th', h(column.header))
          when :action : line += content_tag('th', column.header, :class=>"actiony")
        end
      end
      code  = content_tag('tr',line)
      for record in records
        line = ''
        for column in definition.columns
          case column.nature
            when :datum  :
              datum = column.data(record)
              datum = value_image(datum) if column.datatype==:boolean
              datum = link_to datum, url_for(column.url(record)) if column.is_linkable?
              line += content_tag('td', datum, :class=>column.datatype.to_s)
#              case column.datatype
#                when :date    : line += content_tag('td', , :align=>"center")
#                when :decimal : line += content_tag('td', column.data(record), :align=>"right")
#                when :integer : line += content_tag('td', column.data(record), :align=>"right")
#                when :float   : line += content_tag('td', column.data(record), :align=>"right")
#                when :boolean : line += content_tag('td', value_image(column.data(record)), :align=>"center")
#                else line += content_tag('td', h(column.data(record)))
#              end
            when :action : line += content_tag('td', column.valids_condition(record) ? operation(record, column.options) : "" , :class=>"actiony") 
            else line += content_tag('td','&nbsp;&empty;&nbsp;')
          end
        end
        code += content_tag('tr',line, :class=>cycle('line-odd','line-even'))
      end
    else
      code += content_tag(:tr,content_tag(:td, "No records".t, :colspan=>definition.columns.size, :class=>"norecord"))
    end
    line = ''
    if record_pages
      line += link_to('Previous page'.t, { :page => record_pages.current.previous }) if record_pages.current.previous
      if record_pages.current.next
        line += ' &bull; ' if line.size>0
        line += link_to('Next page'.t, { :page => record_pages.current.next })
      end
    end
    code += content_tag('tr',content_tag('td',line, :colspan=>definition.columns.size, :class=>"navigation")) if line.size>0
    code = content_tag('table', code, :class=>"list")
  end

  def link_to_procedure(procedure, component=nil, part=nil, proc_options={:action=>nil, :id=>nil}, html_options=nil,*parameters_for_method_reference)
    if component.nil?
      path = self.controller.controller_path
    else
      part = self.controller.controller_path.split("/")[0]
      path = part+"/"+component.to_s
    end
    p = PartComponentProcedure.find_by_controller_path_and_name(path, procedure.to_s)
    if p.nil?
      raise Exception.new("Unknown procedure to link to: #{path}::#{procedure.to_s}")
    else
      url = {:controller=>"/"+p.controller_path}
      if proc_options[:action].nil?
        url[:action] = p.default
      else
        url[:action] = proc_options[:action].to_sym
      end
      url[:id] = proc_options[:id] unless proc_options[:id].nil?
      link_to p.title, url, html_options, parameters_for_method_reference
    end
  end

  
  def link_to_actionz(action, component=nil, part=nil, html_options=nil,*parameters_for_method_reference)
    if component.nil?
      path = self.controller.controller_path
    else
      part = self.controller.controller_path.split("/")[0]
      path = part+"/"+component.to_s
    end
    p = PartComponentProcedure.find(:first, :conditions=>["controller_path=? and actions like '%:'||?||':%'",path, action.to_s])
    if p.nil?
      raise Exception.new("Unknown action to link to: #{path}::#{action.to_s}")
    else
      link_to p.title, {:controller=>"/"+path, :action=>action.to_s}, html_options, parameters_for_method_reference
    end
  end

  def submit_tag(value = "Save changes", options = {})
    options.stringify_keys!
    if disable_with = options.delete("disable_with")
      options["onclick"] = "this.disabled=true;this.value='#{disable_with}';this.form.submit();#{options["onclick"]}"
    end
    if url = options.delete("url")
      options["onclick"] = "this.form.setAttribute('action','#{url_for(url)}');this.form.submit();#{options["onclick"]}"
    end
    tag :input, { "type" => "submit", "name" => "toto", "value" => value }.update(options.stringify_keys)
  end

# ******************************************************************************
# **000000***000000***000000**00****00***00000***00000000**0000000**************
# **00***00**00***00****00****00****00**00***00*****00*****00*******************
# **000000***000000*****00*****00**00***0000000*****00*****00000****************
# **00*******00***00****00******0000****00***00*****00*****00*******************
# **00*******00***00**000000*****00*****00***00*****00*****0000000**************
# ******************************************************************************
  private

  def field_box (label, input, position=:right, class_prefix="form")
    code = "<table style=\"width:100%;\"><tr>"
    case position
      when :bottom : code += "<td class=\"#{class_prefix}-label-v\">"+label+"</td></tr><tr><td class=\"#{class_prefix}-input\">"+input+"</td>"
      when :top    : code += "<td class=\"#{class_prefix}-input\">"+input+"</td></tr><tr><td class=\"#{class_prefix}-label-v\">"+label+"</td>"
      when :left   : code += "<td class=\"#{class_prefix}-input\">"+input+"</td><td class=\"#{class_prefix}-label-h\">"+label+"</td>"
      else           code += "<td class=\"#{class_prefix}-label-h\">"+label+"</td><td class=\"#{class_prefix}-input\">"+input+"</td>"
    end
    code += "</tr></table>"
  end

  def label_box (model,attribute, style="form-std")
    column = model.columns_hash[attribute]
    label_box_tag model, attribute, column.human_name, column.required_on, style
  end

  def label_box_tag (model,attribute,label="undefined",required_on=false, style="form-std")
    "<label class=\"#{style}#{' required' if required_on}\" for=\"#{model.class_name.underscore}_#{attribute}\">"+label+"</label>"
  end

  def input7789787987987987_box(model,attribute,options={:cols=>80,:rows=>8, :position=>nil, :type=>nil, :label=>nil, :required_on=>false, :limit=>255})
    input = ""
    style_class = ""
    model_name = ""
    input_type  = options[:type]
    input_limit = options[:limit] || 255
    if not model.nil? and model!=:record and options[:label].nil? and options[:type].nil?
      model_name = model.class_name.underscore
      column = model.columns_hash[attribute]
      style_class = "required" if column.required_on
      if column.text? && column.limit && column.limit<128
        input_type = :string
        input_limit = column.limit
      elsif column.text? && column.limit && column.limit>=128
        input_type = :text
      elsif column.type == :boolean
        input_type = :boolean
      elsif column.type == :date
        input_type = :date
      elsif column.number?
        input_type = :number
      else
        input_type = :textarea
      end
    elsif not options[:label].nil? and not options[:type].nil?
      if model==:record
        model_name = model 
      else
        model_name = model.class_name.underscore
      end
      input_type=:text if input_type==:string and input_limit>=128
      style_class = "required" if options[:required_on]
    else
      raise Exception.new("Undefined text_box")
    end
    input_limit = 64 if input_type==:password and input_limit > 64
    case input_type
      when :string   : input = text_field model_name, attribute, :size=>input_limit+2, :maxlength=>input_limit, :class=>style_class
      when :password : input = password_field  model_name, attribute, :size=>input_limit+2, :maxlength=>input_limit, :class=>style_class
      when :text     : input = text_field model_name, attribute, {:style=>"width:100%", :class=>style_class}
      when :boolean  : input = check_box model_name, attribute , {}, "true", "false"
#      when :date    : input = date_select(model_name, attribute, :order => [:day, :month, :year])
      when :date     : input = text_field model_name, attribute, :maxlength=>16, :class=>style_class
      when :number   : input = text_field model_name, attribute, :maxlength=>32, :class=>style_class
      else input = text_area model_name, attribute, :cols=>options[:cols], :rows=>options[:rows]-1, :style=>"width:100%;", :class=>style_class
    end
    input
  end




end



module PraesensControllerSupport #:nodoc:
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end

  module ClassMethods
  

    def controls(*models)
      for model in models
        if model.is_a? Array
          controls_model model[0], {:company_id=>"@current_company_id"}.merge!(model[1])
        else
          controls_model model, {:company_id=>"@current_company_id"}
        end
      end
    end

    # Class method to automate
    def auto_complete_for(object, association, method, options={}) #:nodoc:
      conditions = ""
      conditions = " AND "+options[:and_conditions].to_s unless options[:and_conditions].nil?
      options.delete(:and_conditions)
      if object.to_s.camelize.constantize.reflections[association].class_name.constantize.columns_hash["company_id"].nil?
        define_method("auto_complete_belongs_to_for_#{object}_#{association}_#{method}") do
          find_options = {
            :conditions => ["LOWER(#{method}) LIKE ? #{conditions}", '%' + params[association][method].downcase + '%'],
            :order => "#{method} ASC",
            :limit => 10
          }.merge!(options)
          klass = object.to_s.camelize.constantize.reflect_on_association(association).options[:class_name].constantize
          @items = klass.find(:all, find_options)
          render :inline => "<%= model_auto_complete_result @items, '#{method}' %>"
        end
      else
        define_method("auto_complete_belongs_to_for_#{object}_#{association}_#{method}") do
          find_options = {
            :conditions => ["LOWER(#{method}) LIKE ? AND company_id=? #{conditions}", '%' + params[association][method].downcase + '%', @current_company_id],
            :order => "#{method} ASC",
            :limit => 10
          }.merge!(options)
          klass = object.to_s.camelize.constantize.reflect_on_association(association).options[:class_name].constantize
          @items = klass.find(:all, find_options)
          render :inline => "<%= model_auto_complete_result @items, '#{method}' %>"
        end
      end
    end


    private
      
    def controls_model(model, conditions={})
      find_conditions = ""
      if conditions.is_a? Hash and conditions.size>0
        for c in conditions
          find_conditions += ",:"+c[0].to_s+"=>"+c[1].to_s
        end
        find_conditions.gsub!(/(^,*|,*$)/,"").squeeze!(",")
        find_conditions  = ",:conditions=>{"+find_conditions+"}"
      end
#      find_conditions = ""
#      , :conditions =>["company_id=?",@current_company_id]
      code = ''
      code << <<-"end_eval"
        def #{model.to_s}_list
          @title = "Listing x".t #{model.to_s.camelize.constantize}.localized_model_name+" ("+@current_company.#{model.to_s.pluralize}.count.to_s+")"
          @#{model.to_s}_pages, @#{model.to_s.pluralize} = paginate :#{model.to_s.pluralize.to_s}, :per_page => 30#{find_conditions}, :order=>:#{model.to_s.camelize.constantize.columns_hash["name"].nil? ? "id" : "name"}
        end
        def #{model}_new
          @title = "Creating x".t #{model.to_s.camelize.constantize}.localized_model_name
          @model = #{model.to_s.camelize.constantize}
          if request.post?
            params[:#{model.to_s}][:company_id] = @current_company_id
            @#{model.to_s} = #{model.to_s.camelize.constantize}.new(params[:#{model.to_s}])
            if @#{model.to_s}.save
              redirect_to :action => '#{model.to_s}_list'
            else
              render :action=>:new
            end
          else
            @#{model.to_s} = #{model.to_s.camelize.constantize}.new
            render :action=>:new
          end
        end
        def #{model}_edit
          @title = "Editing x".t #{model.to_s.camelize.constantize}.localized_model_name
          @model = #{model.to_s.camelize.constantize}
          @#{model.to_s} = #{model.to_s.camelize.constantize}.find(params[:id])
          if request.post?
            if @#{model.to_s}.update_attributes(params[:#{model.to_s}])
              redirect_to :action => '#{model.to_s}_list' 
            else
              render :action=>:edit
            end
          else
            render :action=>:edit
          end
        end
        def #{model}_destroy
          if request.post? or request.delete?
            #{model.to_s.camelize.constantize}.find(params[:id]).destroy
            redirect_to :action => '#{model.to_s}_list'
          end
        end
      end_eval
      ActionController::Base.logger.error(code)
      module_eval(code)
    end
    
  end
end

ActionController::Base.send(:include, PraesensControllerSupport)



# Ouput Table Definition


  class OutputTableColumn
     attr_reader :nature, :options
    def initialize(model, nature=:data, options={:name=>nil, :type=>:string})
      @model           = model
      @nature          = nature
      @options         = options
      if @options[:through].is_a? Array
        if @options[:through].size==1
          @options[:through] = @options[:through][0]
        end
      end
    end
    
    def header
      if @options[:label]
        @options[:label].to_s
      else
        case @nature
          when :datum :
            if @options[:through] and @options[:through].is_a?(Symbol)
#              @model.reflections[@options[:through]].class_name.constantize.localized_model_name
              raise Exception.new("Unknown reflection :#{@options[:through].to_s} for the ActiveRecord: "+@model.to_s) if @model.reflections[@options[:through]].nil?
              @model.columns_hash[@model.reflections[@options[:through]].primary_key_name].human_name
            elsif @options[:through] and @options[:through].is_a?(Array)
              model = @model
              for x in 0..@options[:through].size-2
                model = model.reflections[@options[:through][x]].options[:class_name].constantize
              end
              reflection = @options[:through][@options[:through].size-1].to_sym
              model.columns_hash[model.reflections[reflection].primary_key_name].human_name
            else
              @model.columns_hash[@options[:name].to_s].human_name
            end;
          when :action : 'ƒ'
          else '-'
        end
      end
    end
    
    def data(record)
      if @options[:through]
        if @options[:through].is_a?(Array)
          r = record
          for x in 0..@options[:through].size-1
            r = r.send(@options[:through][x])
          end
          r.nil? ? nil : r.send(@options[:name])
        else
          r = record.send(@options[:through])
          r.nil? ? nil : r.send(@options[:name])
        end
      else
        record.send(@options[:name])
      end
    end
    
    def is_linkable?
      @options[:url]
    end
    
    def url(record)
      @options[:url][:id]= get_record(record).id unless @options[:id] and @options[:id]==:none
      @options[:url]
    end
    
    def datatype
      @model.columns_hash[@options[:name].to_s].type
    end
    
    def valids_condition(record)
      condition = @options[:condition]
      if condition
        cond = condition.to_s
        if cond.match /^not__/
          !record.send(cond[5..255])
        else
          record.send(cond)
        end
      else
        true
      end
    end
    
    private
    
    def get_record(record)
      if @options[:through]
        if @options[:through].is_a?(Array)
          r = record
          for x in 0..@options[:through].size-1
            r = r.send(@options[:through][x])
          end
          r
        else
          record.send(@options[:through])
        end
      else
        record
      end
    end
    
  end

  class OutputTableDefinition
    attr_reader :columns, :data_count, :link_count, :model

    def initialize(model)
      @model = model
      @columns = []
      @data_count = 0
      @link_count = 0
    end

    def datum(name,options={type=>:string})
      options[:name] = name
      @columns << OutputTableColumn.new(@model, :datum, options)
      @data_count += 1      
    end

    def action(options)
      if options.is_a? Hash
        @columns << OutputTableColumn.new(@model, :action, options)
        @link_count += 1      
      elsif options.is_a? Symbol
        case options
          when :none    :
          when :default :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:show})
            @columns << OutputTableColumn.new(@model, :action, {:action=>:edit})
            @columns << OutputTableColumn.new(@model, :action, {:action=>:destroy, :method=>:post, :confirm=>'Are you sure?'})
            @link_count += 3
          when :show    :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:show})
            @link_count += 1
          when :edit    :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:edit})
            @link_count += 1
          when :destroy :
            @columns << OutputTableColumn.new(@model, :action, {:action=>:destroy, :method=>:post, :confirm=>'Are you sure?'})
            @link_count += 1
          else
            @columns << OutputTableColumn.new(@model, :action, {:action=>:options})
            @link_count += 1
        end
      end
    end

  end
  
