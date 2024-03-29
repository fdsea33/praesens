# == Schema Information
# Schema version: 9
#
# Table name: accountancies
#
#  id               :integer       not null, primary key
#  name             :string(255)   
#  comment          :text          
#  master_nature_id :integer       not null
#  currency_id      :integer       not null
#  report_credit_id :integer       not null
#  report_debit_id  :integer       not null
#  profits_id       :integer       not null
#  losses_id        :integer       not null
#  sales_id         :integer       not null
#  purchases_id     :integer       not null
#  newyear_id       :integer       not null
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class Accountancy < ActiveRecord::Base
 
end
