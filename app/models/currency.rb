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
  
  def after_save
    time = Time.now
  	last_one = self.current_version
		add_version = true
		add_version = last_one.rate!=self.rate or last_one.format!=self.format if last_one
		if add_version
	    last_one.update_attribute(:stopped_at, time) if last_one
  	  self.create_in_versions :format=>self.format, :rate=>self.rate, :started_at=>time, :company_id=>self.company_id
		end
  end
  
  def current_version
    self.versions.find(:first, :conditions=>{:stopped_at=>nil})
  end

end
