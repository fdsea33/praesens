# == Schema Information
# Schema version: 9
#
# Table name: delays
#
#  id              :integer       not null, primary key
#  name            :string(255)   not null
#  active          :boolean       not null
#  months          :integer       default(0), not null
#  days            :integer       default(0), not null
#  end_of_month    :boolean       not null
#  additional_days :integer       default(0), not null
#  company_id      :integer       not null
#  created_at      :datetime      
#  created_by      :integer       
#  updated_at      :datetime      
#  updated_by      :integer       
#  lock_version    :integer       default(0), not null
#

class Delay < ActiveRecord::Base

  # Compute a deadline from a date
  def compute(born_on)
    dead_on =(born_on >> self.months) + self.days
    dead_on = dead_on.end_of_month + self.additional_days if self.end_of_month
  end
  
end
