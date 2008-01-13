# == Schema Information
# Schema version: 9
#
# Table name: company_departments
#
#  id                       :integer       not null, primary key
#  name                     :string(255)   not null
#  parent_id                :integer       
#  company_establishment_id :integer       not null
#  company_id               :integer       not null
#  created_at               :datetime      
#  created_by               :integer       
#  updated_at               :datetime      
#  updated_by               :integer       
#  lock_version             :integer       default(0), not null
#

class CompanyDepartment < ActiveRecord::Base
  acts_as_tree
end
