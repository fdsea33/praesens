# == Schema Information
# Schema version: 9
#
# Table name: pricelist_item_versions
#
#  id               :integer       not null, primary key
#  price            :decimal(16, 4 not null
#  price_with_taxes :decimal(16, 4 not null
#  is_active        :boolean       default(TRUE), not null
#  use_range        :boolean       not null
#  quantity_min     :decimal(16, 2 default(0.0), not null
#  quantity_max     :decimal(16, 2 default(0.0), not null
#  product_id       :integer       not null
#  pricelist_id     :integer       not null
#  company_id       :integer       not null
#  item_id          :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class PricelistItemVersion < ActiveRecord::Base
end
