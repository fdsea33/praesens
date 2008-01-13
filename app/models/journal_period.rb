# == Schema Information
# Schema version: 9
#
# Table name: journal_periods
#
#  id               :integer       not null, primary key
#  journal_id       :integer       not null
#  financialyear_id :integer       not null
#  started_on       :date          not null
#  stopped_on       :date          not null
#  closed           :boolean       
#  debit            :decimal(16, 2 default(0.0), not null
#  credit           :decimal(16, 2 default(0.0), not null
#  balance          :decimal(16, 2 default(0.0), not null
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class JournalPeriod < ActiveRecord::Base
  validates_constancy_of :company_id, :journal_id, :started_on, :stopped_on
  validates_constancy_of :financialyear_id, :debit, :credit, :balance, :if=>Proc.new {|p| p.closed}
  
  def before_validation_on_create
    self.company_id = self.journal.company_id
    self.started_on = self.started_on.beginning_of_month
    self.stopped_on = self.started_on.end_of_month
    self.financialyear_id  = self.company.accountancy.master_nature.current_financialyear.id unless self.company.accountancy.master_nature.current_financialyear.nil?
  end

  def validate_on_create
    errors.add(:financialyear_id, "isn't defined. Maybe there is no opened financial year") if self.financialyear.nil?
    errors.add_to_base("This period is closed, therefore it can be created") if self.closed or (self.financialyear and self.financialyear.closed)
    errors.add_to_base("It is impossible to use this period because it's closed") unless self.started_on > self.journal.closed_on
    errors.add(:started_on, "have to be the first day of the month") if self.started_on.beginning_of_month!=self.started_on
    errors.add(:stopped_on, "have to be after the opening date") if self.started_on>self.stopped_on
    errors.add(:stopped_on, "have to be the last day of the month of the opening date") if self.started_on.end_of_month!=self.stopped_on
    errors.add_to_base("This period already exists") unless JournalPeriod.find(:first, :conditions=>{:company_id=>self.company_id, :journal_id=>self.journal_id, :financialyear_id=>self.financialyear_id, :started_on=>self.started_on, :stopped_on=>self.stopped_on}).nil?
  end
  
  def validate_on_update
    old = JournalPeriod.find(self.id)
    errors.add_to_base("This period is closed, therefore it can be modified") if old and old.closed
  end

  def before_save
    self.debit      = self.journal_records.sum(:debit) || 0
    self.credit     = self.journal_records.sum(:credit) || 0
    self.balance    = self.debit-self.credit
  end

  def after_save
    self.financialyear.save
  end

end
