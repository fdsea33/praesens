# == Schema Information
# Schema version: 8
#
# Table name: part_component_procedures
#
#  id              :integer       not null, primary key
#  name            :string(255)   not null
#  controller_path :string(255)   default("[NoControllerPath]"), not null
#  contextual      :boolean       not null
#  actions         :text          default(":"), not null
#  component_id    :integer       not null
#  parent_id       :integer       
#  position        :integer       
#  created_at      :datetime      
#  created_by      :integer       
#  updated_at      :datetime      
#  updated_by      :integer       
#  lock_version    :integer       default(0), not null
#

class PartComponentProcedure < ActiveRecord::Base
  attr_accessor :active
  acts_as_list :scope=>:component_id
  acts_as_tree :order=>:position


  def before_create
    self.controller_path = self.component.part.name+"/"+self.component.name
  end

  def default(index=0)
    self.actions.split(":")[index+1]
  end

  def title
    l :parts, self.component.part.name, :components, self.component.name, :procedures, self.name, :title
  end

  def description
    l :parts, self.component.part.name, :components, self.component.name, :procedures, self.name, :description
  end
  
  def action_title(action)
    if action.is_a? Integer
      action_name = self.default(action)
    elsif action.is_a? String
      action_name = action
    end
    title = ''
    begin
      title = l!(:parts, self.component.part.name, :components, self.component.name, :procedures, self.name, :actions,action_name)
    rescue
      title = self.title
    end
  end

end
