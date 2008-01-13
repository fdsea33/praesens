# == Schema Information
# Schema version: 9
#
# Table name: financialyears
#
#  id           :integer       not null, primary key
#  code         :string(12)    not null
#  nature_id    :integer       not null
#  closed       :boolean       not null
#  started_on   :date          not null
#  stopped_on   :date          not null
#  written_on   :date          not null
#  debit        :decimal(16, 2 default(0.0), not null
#  credit       :decimal(16, 2 default(0.0), not null
#  position     :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Financialyear < ActiveRecord::Base
  validates_constancy_of :started_on, :type_id
  validates_constancy_of :stopped_on, :written_on, :if=>Proc.new { |y| y.closed? }
  acts_as_list :scope=>:type_id

  def initialize(*params)
    super(*params)
    if new_record? and !self.type_id.nil? and self.started_on.nil? and self.stopped_on.nil? and written_on.nil? and code.nil?
      financialyear_type = self.type
      self.company_id = self.type.company_id
      month_nb = financialyear_type.month_number
      last_year = self.company.financialyears.find(:first, :order=>"started_on DESC", :conditions=>{:type_id=>financialyear_type.id})
      self.started_on = last_year.nil? ? Date.today : last_year.stopped_on+1
      self.started_on = Date.civil(self.started_on.year, self.started_on.month, 1)
      self.stopped_on = (self.started_on>>month_nb)-1
      self.written_on = self.stopped_on>>(month_nb/2).round
      self.code = financialyear_type.code+"/"+self.started_on.year.to_s
      if financialyear_type.month_number==12 and self.started_on.year != self.stopped_on.year
        year = self.stopped_on.year
        self.code += "-"+year.to_s[year.size-2, year.size-1]
        self.code += "-1" if self.company.financialyears.find_by_code(self.code)
      elsif financialyear_type.month_number<12 and last_year and last_year.stopped_on.year!=last_year.started_on.year
        self.code = last_year.code.succ
      elsif financialyear_type.month_number<12
        self.code += "-A"  
      end
      while self.company.financialyears.find_by_code(self.code)
        self.code.succ!
      end
    end
  end

  def validate
    errors.add_to_base("The limit date to authorize writing on a financial year must be after the stop date") if self.written_on < self.stopped_on
    errors.add(:written_on, "The limit date to authorize writing on a financial year is too far") if self.written_on > self.stopped_on >> self.type.month_number*2
    errors.add(:stopped_on, "The stop date must be a last day of month")  unless self.stopped_on = self.stopped_on.end_of_month
    errors.add(:stopped_on, "The stop date must be after the start date") unless self.started_on < self.stopped_on
  end
  
  def validate_on_create
    errors.add_to_base("A closed financial year can't be created") if self.closed
    errors.add_to_base("Only one financial year can be opened by type at the same time") unless self.type.can_open_financialyear?
    errors.add(:started_on, "The start date must be a first day of month") if self.started_on!=self.started_on.beginning_of_month and !self.type.new_type?
  end

  def validate_on_update
    old = Financialyear.find(self.id)
    errors.add_to_base("A closed financial year can't be updated") if old and old.closed
  end
  
  def valid_closure(closure)
    return "This financial year is already closed" if self.closed
#    return "It is impossible to close a financial year during and after today" if closure>=Date.today
    return "It is impossible to close a financial year before its beginning" if closure<=self.started_on
    return "A financial year can only be closed on an end of month" if closure!=closure.end_of_month
    return "The 'new year' journal must be opened" if self.company.accountancy.newyear.closed_on>=closure
    for journal in self.company.journals
      report = journal.valid_closure(closure)
      return report unless report.nil?
    end
    return nil
  end

  
  def next_year
    Financialyear.find :first, :conditions=>["position>? AND type_id=?",self.position, self.type_id], :order=>"position"
  end
  
  def previous_year
    Financialyear.find :first, :conditions=>["position<? AND type_id=?",self.position, self.type_id], :order=>"position DESC"
  end

  def compute_balance(force_compute=false)
    if !self.closed or force_compute
      self.delete_all("financialyear_id=#{financialyear.id}")
      account = self.company.accounts.find(:first, :conditions=>"parent_id=0")
      account.compute_balance(self)
#      self.compute_account(account)
#      AccountBalance.generate(account, self)
    else
      nil
    end
  end


  def balance
    self.compute_balance
    abs = self.account_balances
    balance = {}
    for ab in abs
      num = ab.account.number.to_s
      balance[num] = ab.attributes
    end
    balance
  end


  # Work well if the balance is done before
  def has_something_to_transfer?
    abs = AccountBalance.find(:all, :conditions=>["financialyear_id=? and local_count>0", self.id])
    for ab in abs
      return true if ab.account.transferable? and (ab.account.keep_entries or ab.local_balance!=0)
    end
    return false
  end

  def close(closure)
    report = valid_closure(closure)
    if report.nil?
      # Clôture de l'exercice
      self.stopped_on = closure
      self.save!
      # Résultat N
      accountancy = self.company.accountancy
      journal     = accountancy.newyear
      charges     = Account.find_by_company_id_and_number(self.company_id, "6").compute_balance
      products    = Account.find_by_company_id_and_number(self.company_id, "7").compute_balance
#      charges     = AccountBalance.generate(Account.find_by_company_id_and_number(self.company_id, "6"), self)
#      products    = AccountBalance.generate(Account.find_by_company_id_and_number(self.company_id, "7"), self)
      result      = (charges.global_credit+products.global_credit)-(charges.global_debit+products.global_debit)
      if result!=0
        currency = accountancy.currency
        record   = JournalRecord.create!(:journal=>journal, :company=>self.company, :printed_on=>self.stopped_on, :number=>journal.new_record_number)
        Entry.create! :record=>record, :account=>charges.account,  :name=>charges.account.name,  :currency=>currency, :currency_credit=>charges.global_debit,  :currency_debit=>charges.global_credit
        Entry.create! :record=>record, :account=>products.account, :name=>products.account.name, :currency=>currency, :currency_debit=>products.global_credit, :currency_credit=>products.global_debit
        if result>0
          # Benefits
          Entry.create! :record=>record, :account=>accountancy.profits, :name=>journal.name, :currency=>currency, :currency_credit=>result
        else
          # Losses
          Entry.create! :record=>record, :account=>accountancy.losses, :name=>journal.name, :currency=>currency, :currency_debit=>0-result
        end
      end
      # Re-cumul par compte N
      self.compute_balance
#      AccountBalance.compute_all(self.id)
      # Clôture des journaux          
      for journal in self.company.journals
        journal.close(closure)
      end
      # Clôture de l'exercice
      self.reload()
      self.closed = true
      self.save
      # Création du nouvel exercice
      newyear = Financialyear.create! :company_id=>self.company_id, :type_id=>self.type_id
      # A nouveau N+1
      if self.has_something_to_transfer?
        journal = accountancy.newyear
        period  = accountancy.newyear.period_at(newyear.started_on)
        record  = JournalRecord.create!(:journal=>journal, :printed_on=>newyear.started_on, :number=>journal.new_record_number, :period=>period)
        abs = AccountBalance.find(:all, :conditions=>["financialyear_id=?", self.id])
        for ab in abs
          if ab.account.transferable?
            if ab.account.keep_entries
              entries = ab.account.entries.find(:all, :select=>"e.*", :joins=>"AS e JOIN journal_records AS r ON (e.record_id=r.id) JOIN journal_period AS p ON (r.period_id=p.id) JOIN financialyear AS f ON (p.financialyear_id=f.id)", :conditions=>["f.id=?",self.id])
              for entry in entries
                Entry.create! :record=>record, :account=>entry.account, :name=>entry.name, :currency=>entry.currency, :currency_rate=>entry.currency_rate, :currency_debit=>entry.debit, :currency_credit=>entry.credit
              end
            elsif ab.local_balance!=0
              debit = 0
              credit = 0
              if ab.local_balance>0
                debit = ab.local_balance
              else
                credit = 0-ab.local_balance
              end
              Entry.create! :record=>record, :account=>ab.account, :name=>ab.account.name, :currency=>currency, :currency_debit=>debit, :currency_credit=>credit
            end
          end
        end
      end
      return nil
    else
      return report
    end
  end

end
