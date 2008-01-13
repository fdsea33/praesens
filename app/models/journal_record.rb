# == Schema Information
# Schema version: 8
#
# Table name: journal_records
#
#  id           :integer       not null, primary key
#  created_on   :date          not null
#  printed_on   :date          not null
#  number       :integer       not null
#  status       :string(1)     default("A"), not null
#  debit        :decimal(16, 2 default(0.0), not null
#  credit       :decimal(16, 2 default(0.0), not null
#  balance      :decimal(16, 2 default(0.0), not null
#  position     :integer       not null
#  period_id    :integer       not null
#  journal_id   :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class JournalRecord < ActiveRecord::Base
  validates_constancy_of :journal_id
  acts_as_list :scope=>:journal_id
  
  def initialize(*params)
    super(*params)
    if (@new_record)
      self.number = self.journal.new_record_number if self.number.nil? and !self.journal.nil?
      self.printed_on = Date.today if self.printed_on.nil?
      self.status = "C"
    end
  end
  
  def before_validation_on_create
    self.created_on = Date.today
    self.status     = "C"
    if self.journal and self.created_on > self.journal.closed_on and self.period.nil?
      self.period = self.journal.period_at(self.created_on)
    end
    self.company_id = self.journal.company_id if self.journal
  end
  
  def validate_on_create
    errors.add_to_base("The journal is not opened for the current period".t) if self.period.nil?
#    errors.add_to_base("The journal is closed for this period".t) if self.period and self.period.closed
    errors.add_to_base("One financial year must be opened to permit the writing of records".t) if self.company.accountancy.master_nature.can_open_financialyear?
  end
  
  
  def before_save
    self.debit   = self.entries.sum(:debit) || 0
    self.credit  = self.entries.sum(:credit) || 0
    self.balance = self.debit-self.credit
    if self.status != "D"
      self.status = self.balance==0 ? "A" : "B"
    end
  end
  
  def after_save
    self.period.save
  end
  
  def after_destroy
    self.period.save
  end
  
  def refresh
    self.save
  end
  
end
