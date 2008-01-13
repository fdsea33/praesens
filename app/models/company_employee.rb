# == Schema Information
# Schema version: 9
#
# Table name: company_employees
#
#  id                    :integer       not null, primary key
#  company_department_id :integer       not null
#  user_id               :integer       
#  title                 :string(32)    not null
#  surname               :string(255)   not null
#  first_name            :string(255)   not null
#  arrived_on            :date          not null
#  role                  :string(255)   
#  phone                 :string(32)    
#  email                 :string(255)   
#  mobile                :string(32)    
#  fax                   :string(32)    
#  office                :string(32)    
#  note                  :text          
#  company_id            :integer       not null
#  created_at            :datetime      
#  created_by            :integer       
#  updated_at            :datetime      
#  updated_by            :integer       
#  lock_version          :integer       default(0), not null
#

class CompanyEmployee < ActiveRecord::Base
#  schema_validations :except=> [:arrived_on]

end
