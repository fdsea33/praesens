# == Schema Information
# Schema version: 9
#
# Table name: currencies
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  code         :string(255)   not null
#  format       :string(16)    not null
#  rate         :decimal(16, 6 default(1.0), not null
#  active       :boolean       default(TRUE), not null
#  comment      :text          
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Currency < ActiveRecord::Base

  validates_constancy_of :code
  
  def before_save
    old = Currency.find_by_id self.id
    new = self
    if not old or (old.format!=new.format or old.rate!=new.rate)
      time = Time.now
      last_one = CurrencyRate.find_by_currency_id(self.id, :order=>"started_at DESC")
      if last_one
        last_one.stopped_at = time 
        last_one.save
      end
      new_one = self.create_in_rates :format=>self.format, :rate=>self.rate, :started_at=>time, :company_id=>self.company_id
    end
  end
  
  def current_rate
    self.rates.find(:first, :conditions=>{:stopped_at=>nil})
  end

end
