# == Schema Information
# Schema version: 8
#
# Table name: products
#
#  id                  :integer       not null, primary key
#  name                :string(255)   not null
#  number              :integer       not null
#  code                :string(32)    not null
#  ean13               :string(13)    
#  catalog_name        :string(255)   not null
#  catalog_description :text          
#  description         :text          
#  account_id          :integer       not null
#  company_id          :integer       not null
#  created_at          :datetime      not null
#  created_by          :integer       
#  updated_at          :datetime      not null
#  updated_by          :integer       
#  lock_version        :integer       default(0), not null
#

class Product < ActiveRecord::Base
end
