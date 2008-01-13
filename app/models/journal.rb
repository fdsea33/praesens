# == Schema Information
# Schema version: 9
#
# Table name: journals
#
#  id             :integer       not null, primary key
#  nature_id      :integer       not null
#  name           :string(255)   not null
#  code           :string(4)     not null
#  counterpart_id :integer       
#  closed_on      :date          default(#<Date: 4534211/2,0,2299161>), not null
#  company_id     :integer       not null
#  created_at     :datetime      
#  created_by     :integer       
#  updated_at     :datetime      
#  updated_by     :integer       
#  lock_version   :integer       default(0), not null
#

class Journal < ActiveRecord::Base
  validates_constancy_of :nature_id, :company_id

  def validate_on_update
    old = Journal.find self.id
    new = self
    errors.add(:closed_on, "must be later than the last closure date") if new.closed_on<old.closed_on
    errors.add(:closed_on, "must be the last day of the month") if self.closed_on!=self.closed_on.end_of_month
  end

  def validate
#    errors.add(:closed_on, "can't be later than today") if  self.closed_on>=Date.today
  end

  
  def last_records(x)
    records = self.records.find(:all, :limit=>x, :order=>"position DESC").collect{|x| x.id}.join(",")
    if !records.nil? and records.size>0
      self.records.find(:all, :conditions=>"id IN (#{records})", :order=>"position ASC")
    else
      []
    end
  end
  
  def valid_closure(closure)
    opening = self.closed_on+1
#      return "A journal must be closed before today" if closure>=Date.today
    return "A journal can only be closed on an end of month" if closure!=closure.end_of_month
    return "A journal can't be closed before its last closure" unless closure>opening
    all_records  = self.records.find(:all, :conditions=>["created_on BETWEEN ? AND ?", opening, closure]).size
    good_records = self.records.find(:all, :conditions=>["created_on BETWEEN ? AND ? AND status='A'", opening, closure]).size
    return "A journal can't be closed with invalid records" unless all_records==good_records
    return nil
  end
  
  def new_record_number
    r = self.records.find(:first, :order=>"position DESC")
    if r 
      r.number.succ
    else
      "0"
    end      
  end

  def period_at(active_on)
    periods = self.periods.find(:all, :conditions=>["? BETWEEN started_on AND stopped_on", active_on])
    if periods.size==1
      period = periods[0]
    elsif periods.size==0
      period = self.periods.create :company_id=>self.company_id, :started_on=>active_on
    else
      raise Exception.new("There are bad periods for the journal x".t(self.name))
    end
  end
  
  def periods_at(started_on, stopped_on)
    active_on = started_on
    periods= {}
    periods["debit"]  = 0.0.to_d
    periods["credit"] = 0.0.to_d
    while active_on<=stopped_on
      period = self.period_at(active_on)
      periods["debit"]  += period.debit
      periods["credit"] += period.credit
      active_on = active_on>>1
    end
    periods["balance"] = periods["debit"]-periods["credit"]
    periods
  end
  

  def close(closure)
    report = valid_closure(closure)
    if report.nil?
      if closure>self.closed_on
        periods = self.periods.find(:all, :conditions=>["stopped_on<=? and not closed", closure])
        for period in periods
          period.closed = true
          period.save!
        end
        self.closed_on = closure
        self.save!
      elsif closure<self.closed_on
        # rien pour l'instant
      end
      nil
    else
      report
    end
  end

end
