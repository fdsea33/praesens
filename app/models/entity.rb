# == Schema Information
# Schema version: 8
#
# Table name: entities
#
#  id               :integer       not null, primary key
#  nature_id        :integer       not null
#  language_id      :integer       not null
#  code             :string(255)   not null
#  surname          :string(255)   not null
#  first_name       :string(255)   
#  full_name        :string(255)   not null
#  active           :boolean       default(TRUE), not null
#  born_on          :date          
#  ean13            :string(13)    
#  surname_soundex2 :string(4)     
#  web_site         :string(255)   
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class Entity < ActiveRecord::Base

  def before_validation
    self.code = "P"+(rand*10000).to_i.to_s
    self.surname_soundex2 = self.surname.soundex2
    self.full_name = "-"
  end
  
  def before_save
    self.surname.upcase!
    self.first_name.capitalize!
    self.full_name = self.nature.title+" "+self.surname+" "+self.first_name+" ("+self.code+")"
  end

end
