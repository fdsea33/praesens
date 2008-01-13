# == Schema Information
# Schema version: 8
#
# Table name: roles
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  admin        :boolean       not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Role < ActiveRecord::Base
  ADMINISTRATOR = "Administrator"
  PUBLIC = "Public"
  has_many :procedures, :through => :rights, :source=>:procedure
  has_many :allowed_procedures, :through => :rights, :source=>:procedure, :conditions=>"active"

  def recover_all_rights(order = :position)
    rights = []
    for procedure in PartComponentProcedure.find :all, :order=>order
      if self.procedures.detect { |a| a.id==procedure.id }
        right = Right.find_by_procedure_id_and_role_id(procedure.id, self.id)
      else
        right = Right.create :role_id=>self.id, :procedure_id=>procedure.id, :active=>false
      end
      rights << right
    end
    rights
  end

  def parent_rights(component)
    Right.find :all, :select=>"r.*", :joins=>"AS r JOIN part_component_procedures AS p ON r.part_component_procedure_id=p.id", :conditions=>["p.parent_id IS NULL AND r.component_id=?",component.id]
  end  
  
  def authorize_action?(action_name, controller_path)
 	  controller_path.split("/")[0] == 'public' or self.admin or self.allowed_procedures.detect { |procedure|
	    Regexp.new("(\w:)*:"+action_name+":(\w:)*") =~ procedure.actions && procedure.controller_path == controller_path } ? true : false
  end

  def authorize_procedure?(procedure_name, controller_path)
    controller_path.split("/")[0] == 'public' or self.admin or self.allowed_procedures.detect { |procedure|
      procedure_name == procedure.name && procedure.controller_path == controller_path } ? true : false
  end

end
