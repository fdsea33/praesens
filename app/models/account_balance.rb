# == Schema Information
# Schema version: 9
#
# Table name: account_balances
#
#  id               :integer       not null, primary key
#  account_id       :integer       not null
#  financialyear_id :integer       not null
#  global_debit     :decimal(16, 2 default(0.0), not null
#  global_credit    :decimal(16, 2 default(0.0), not null
#  global_balance   :decimal(16, 2 default(0.0), not null
#  global_count     :integer       default(0), not null
#  local_debit      :decimal(16, 2 default(0.0), not null
#  local_credit     :decimal(16, 2 default(0.0), not null
#  local_balance    :decimal(16, 2 default(0.0), not null
#  local_count      :integer       default(0), not null
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

class AccountBalance < ActiveRecord::Base

  def before_save
    self.global_balance = self.global_debit - self.global_credit
    self.local_balance  = self.local_debit  - self.local_credit
  end

#  def self.compute_all(financialyear_id, force_compute=false)
#    financialyear = Financialyear.find(financialyear_id)
#    if !financialyear.closed or force_compute
#      self.delete_all("financialyear_id=#{financialyear.id}")
#      accounts = Account.find_all_by_company_id_and_parent_id(financialyear.company, nil)
#      for account in accounts
#        AccountBalance.generate(account, financialyear)
#      end
#      nil
#    end
#  end

  # Find or init and compute the balance
#  def compute_balance(account, financialyear)
#    ab = AccountBalance.find_or_initialize_by_company_id_and_account_id_and_financialyear_id(account.company_id,account.id,financialyear.id)
#    ab.compute
#    ab
#  end

  # Compute the debit and credit for an account and its children
  def compute
    started_on = self.financialyear.started_on
    stopped_on = self.financialyear.stopped_on
    debit  = self.account.entries.sum(:debit,  :select=>"entries.debit",  :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on]) || 0
    credit = self.account.entries.sum(:credit, :select=>"entries.credit", :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on]) || 0
    count  = self.account.entries.count(:select=>"entries", :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on]) || 0
    self.local_debit   = debit
    self.local_credit  = credit
    self.local_count   = count
    for child in self.account.children
#      ab = child.compute_balance(AccountBalance.generate(child, self.financialyear)
      ab = child.compute_balance(self.financialyear)
      debit  += ab.global_debit
      credit += ab.global_credit
      count  += ab.global_count
    end
    self.global_debit  = debit
    self.global_credit = credit
    self.global_count  = count
    self.save!
  end
  
end
