# == Schema Information
# Schema version: 8
#
# Table name: banks
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  code         :string(16)    not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Bank < ActiveRecord::Base
end
