# == Schema Information
# Schema version: 9
#
# Table name: financialyear_natures
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  code         :string(2)     not null
#  fiscal       :boolean       not null
#  month_number :integer       default(12), not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class FinancialyearNature < ActiveRecord::Base

  validates_uniqueness_of :company_id
  validates_inclusion_of :month_number, :in=>1..12

  def before_validation
    self.code.upcase!
  end

  def new_type?
    self.financialyears.count==0
  end

  def can_open_financialyear?
    opened_count = 0
    for fy in self.financialyears
      opened_count += 1 unless fy.closed
    end
    opened_count == 0 ? true : false
  end
  
  def current_financialyear
    self.financialyears.find(:first, :conditions=>{:closed=>false})
  end
  
end
