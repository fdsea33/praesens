# == Schema Information
# Schema version: 8
#
# Table name: tax_versions
#
#  id            :integer       not null, primary key
#  name          :string(255)   not null
#  is_reductible :boolean       default(TRUE), not null
#  amount        :decimal(16, 2 default(0.0), not null
#  rate          :decimal(16, 2 default(0.0), not null
#  description   :text          
#  account_id    :integer       not null
#  company_id    :integer       not null
#  tax_id        :integer       not null
#  created_at    :datetime      not null
#  created_by    :integer       
#  updated_at    :datetime      not null
#  updated_by    :integer       
#  lock_version  :integer       default(0), not null
#

class TaxVersion < ActiveRecord::Base
end
