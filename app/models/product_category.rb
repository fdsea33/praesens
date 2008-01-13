# == Schema Information
# Schema version: 9
#
# Table name: product_categories
#
#  id                  :integer       not null, primary key
#  name                :string(255)   not null
#  catalog_name        :string(255)   not null
#  catalog_description :text          
#  description         :text          
#  parent_id           :integer       
#  company_id          :integer       not null
#  created_at          :datetime      
#  created_by          :integer       
#  updated_at          :datetime      
#  updated_by          :integer       
#  lock_version        :integer       default(0), not null
#

class ProductCategory < ActiveRecord::Base
end
