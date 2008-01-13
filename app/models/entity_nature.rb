# == Schema Information
# Schema version: 9
#
# Table name: entity_natures
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  active       :boolean       default(TRUE), not null
#  physical     :boolean       not null
#  title        :string(255)   not null
#  description  :text          
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class EntityNature < ActiveRecord::Base
end
