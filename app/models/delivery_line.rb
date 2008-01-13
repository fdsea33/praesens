# == Schema Information
# Schema version: 8
#
# Table name: delivery_lines
#
#  id               :integer       not null, primary key
#  delivery_id      :integer       not null
#  estimate_line_id :integer       not null
#  product_id       :integer       not null
#  pricelist_id     :integer       not null
#  price_id         :integer       not null
#  price_version_id :integer       not null
#  quantity         :decimal(16, 2 default(1.0), not null
#  price            :decimal(16, 2 default(0.0), not null
#  taxed_price      :decimal(16, 2 default(0.0), not null
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class DeliveryLine < ActiveRecord::Base
end
