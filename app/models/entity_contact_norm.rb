# == Schema Information
# Schema version: 9
#
# Table name: entity_contact_norms
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  reference    :string(255)   
#  preferred    :boolean       not null
#  rtl          :boolean       not null
#  align        :string(7)     default("left"), not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class EntityContactNorm < ActiveRecord::Base
end
