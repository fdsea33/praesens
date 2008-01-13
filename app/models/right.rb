# == Schema Information
# Schema version: 9
#
# Table name: rights
#
#  id           :integer       not null, primary key
#  role_id      :integer       not null
#  active       :boolean       default(TRUE), not null
#  procedure_id :integer       not null
#  component_id :integer       not null
#  part_id      :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Right < ActiveRecord::Base

  def before_validation
    unless self.procedure_id.nil?
      self.component_id = self.procedure.component_id
      self.part_id = self.component.part_id
    end
  end

  def children
    Right.find :all, :select=>"r.*", :joins=>"AS r JOIN part_component_procedures AS p ON r.procedure_id=p.id", :conditions=>["p.parent_id=?", self.part_component_procedure_id]
  end

  def title
    self.procedure.title
  end

end
