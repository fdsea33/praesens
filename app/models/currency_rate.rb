# == Schema Information
# Schema version: 8
#
# Table name: currency_rates
#
#  id           :integer       not null, primary key
#  format       :string(16)    not null
#  rate         :decimal(16, 6 default(1.0), not null
#  started_at   :datetime      default(Thu Jan 01 01:00:00 +0100 1970), not null
#  stopped_at   :datetime      
#  currency_id  :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class CurrencyRate < ActiveRecord::Base
  validates_constancy_of :format, :rate, :currency_id, :started_at
end
