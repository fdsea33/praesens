# == Schema Information
# Schema version: 9
#
# Table name: entity_contact_versions
#
#  id             :integer       not null, primary key
#  contact_id     :integer       not null
#  installed_at   :datetime      
#  abandoned_at   :datetime      
#  ligne_2        :string(38)    
#  ligne_3        :string(38)    
#  ligne_4_number :string(38)    
#  ligne_4_street :string(38)    
#  ligne_5        :string(38)    
#  ligne_6_code   :string(38)    
#  ligne_6_city   :string(38)    
#  phone          :string(32)    
#  fax            :string(32)    
#  mobile         :string(32)    
#  email          :string(255)   
#  created_at     :datetime      
#  created_by     :integer       
#  updated_at     :datetime      
#  updated_by     :integer       
#  lock_version   :integer       default(0), not null
#

class EntityContactVersion < ActiveRecord::Base
end
