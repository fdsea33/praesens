# == Schema Information
# Schema version: 8
#
# Table name: product_taxes
#
#  id           :integer       not null, primary key
#  amount       :decimal(16, 2 default(0.0), not null
#  product_id   :integer       not null
#  tax_id       :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      not null
#  created_by   :integer       
#  updated_at   :datetime      not null
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class ProductTax < ActiveRecord::Base
end
