# == Schema Information
# Schema version: 8
#
# Table name: entity_contact_norm_items
#
#  id              :integer       not null, primary key
#  contact_norm_id :integer       not null
#  title           :string(255)   not null
#  nature          :string(15)    default("content"), not null
#  maxlength       :integer       default(38), not null
#  content         :string(255)   
#  left_nature     :string(15)    
#  left_value      :string(63)    
#  right_nature    :string(15)    default("space")
#  right_value     :string(63)    
#  position        :integer       
#  company_id      :integer       not null
#  created_at      :datetime      
#  created_by      :integer       
#  updated_at      :datetime      
#  updated_by      :integer       
#  lock_version    :integer       default(0), not null
#

class EntityContactNormItem < ActiveRecord::Base
  validates_inclusion_of :maxlength, :in=> 1..38
  acts_as_list :scope=>:entity_contact_norm_id
  
  NATURE = [["Surname".t,"surname"],["First name".t,"first_name"],["Entity title".t,"title"],["Room - Addressee".t,"line_2"],["Building - Zone".t,"line_3"],["Number in the street".t,"line_4_number"],["Type and name of the street".t,"line_4_street"],["Delivery mention".t,"line_5"],["Postal code".t,"line_6_code"],["City".t,"line_6_city"], ["Static text".t,"text"]]
  LEFT_NATURE = [["Empty".t,"nil"],["End of line".t,"eol"],["Space".t,"space"],["Static text".t,"text"]]
  RIGHT_NATURE = LEFT_NATURE
  
end
