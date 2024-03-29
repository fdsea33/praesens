# == Schema Information
# Schema version: 9
#
# Table name: estimate_natures
#
#  id               :integer       not null, primary key
#  code             :string(16)    not null
#  name             :string(255)   not null
#  expiration_id    :integer       not null
#  is_active        :boolean       default(TRUE), not null
#  payment_delay_id :integer       not null
#  downpayment_rate :decimal(16, 2 default(0.0), not null
#  note             :text          
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class EstimateNature < ActiveRecord::Base
end
