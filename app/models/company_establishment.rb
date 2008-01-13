# == Schema Information
# Schema version: 9
#
# Table name: company_establishments
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  nic          :string(5)     not null
#  siret        :string(255)   not null
#  address      :text          
#  note         :text          
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class CompanyEstablishment < ActiveRecord::Base
  validates_length_of :nic, :is=>5

  def before_validation
    self.siret = self.company.siren+self.nic
  end
  
  def before_update
    self.siret = self.company.siren+self.nic
  end
  
end
