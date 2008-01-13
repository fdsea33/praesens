# == Schema Information
# Schema version: 9
#
# Table name: deliveries
#
#  id           :integer       not null, primary key
#  estimate_id  :integer       not null
#  invoice_id   :integer       not null
#  delivered_on :date          not null
#  price        :decimal(16, 2 default(0.0), not null
#  taxed_price  :decimal(16, 2 default(0.0), not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Delivery < ActiveRecord::Base
end
