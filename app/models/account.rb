# == Schema Information
# Schema version: 9
#
# Table name: accounts
#
#  id           :integer       not null, primary key
#  number       :string(16)    not null
#  alpha        :string(16)    
#  name         :string(208)   not null
#  label        :string(255)   not null
#  usable       :boolean       not null
#  groupable    :boolean       not null
#  keep_entries :boolean       not null
#  transferable :boolean       not null
#  letterable   :boolean       not null
#  pointable    :boolean       not null
#  is_debit     :boolean       not null
#  last_letter  :string(8)     
#  comment      :text          
#  delay_id     :integer       
#  entity_id    :integer       
#  parent_id    :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Account < ActiveRecord::Base
  acts_as_tree
  validates_constancy_of :number
#  validates_numericality_of :number
  
  def before_validation
    self.number.upcase! unless self.number.nil?
    unless self.alpha.nil?
      self.alpha.upcase!
      self.alpha.gsub!(" ","")
      self.alpha = nil unless self.alpha.size>0
    end
    # Parent
    self.parent_id=nil if self.number!="*" and self.parent_id==0
    if self.parent.nil? and self.number and self.number!="*"
      parent_length = self.number.size-2
      parent = nil
      if parent_length>=0
        while not parent = self.company.accounts.find_by_number(self.number[0..parent_length]) and parent_length>=0
          parent_length -= 1  
        end
      end
      if parent_length<0
        parent = self.company.accounts.find_by_number("*")
        if parent.nil?
          parent = Account.create({:number=>"*", :name=>"Accounting".t, :company_id=>self.company_id, :comment=>"Root of the accounting (never used)", :usable=>false, :parent_id=>0})
        end
      end
      self.parent_id = parent.id if parent
    end
    self.label = "label"
  end
  
  def validate
    unless self.number.nil?
      errors.add_to_base("can't be its proper parent") unless self.number=="*" or self.id != self.parent_id
      errors.add(:number, "is not valid (Only capitals and numbers)") unless self.number.match(/^(\*|[1-9][A-Z0-9]*)$/)
      if self.number.size>1 and !self.parent_id.nil?
        errors.add(:number, "is not a valid account number because of its parent") unless self.number[0..self.parent.number.size-1]==self.parent.number
      end
    end
    errors.add(:alpha,  "is not valid (Only capitals and numbers)") unless self.alpha.match(/^[A-Z0-9]*$/) unless self.alpha.nil?
  end

  def validate_on_destroy
    errors.add_to_base("An used account can't be deleted") if self.entries.size>0 or self.children.size>0
  end

  
  def before_save
    alpha = self.alpha.nil?  ? "" : ":"+self.alpha
    self.label = self.number+alpha+". "+self.name
  end

  def after_save
    if self.number!="*"
      accounts = self.company.accounts.find(:all, :conditions=>["parent_id=? AND id!=? AND number LIKE ?",self.parent_id,self.id,self.number+"%"])
      for account in accounts
        account.update_attribute :parent_id, self.id
      end
    end
  end


  
  def transferable?
    self.transferable or (self.parent and self.parent.transferable?)
  end
  
  
  def compute_balance(financialyear)
    ab = AccountBalance.find_or_initialize_by_company_id_and_account_id_and_financialyear_id(self.company_id,self.id,financialyear.id)
    ab.compute
    ab
  end

  def compute(balance, started_on, stopped_on)
    debit  = self.entries.sum(:debit,  :select=>"entries.debit",  :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on]) || 0
    credit = self.entries.sum(:credit, :select=>"entries.credit", :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on]) || 0
    count  = self.entries.count(:select=>"entries", :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on]) || 0
    balance[self.number.to_s] = {}
    balance[self.number.to_s]["local_debit"]   = debit
    balance[self.number.to_s]["local_credit"]  = credit
    balance[self.number.to_s]["local_count"]   = count
    for child in self.children
      child.compute(balance, started_on, stopped_on)
      debit  += balance[child.number.to_s]["global_debit"]
      credit += balance[child.number.to_s]["global_credit"]
      count  += balance[child.number.to_s]["global_count"]
    end
    balance[self.number.to_s]["global_debit"]  = debit
    balance[self.number.to_s]["global_credit"] = credit
    balance[self.number.to_s]["global_count"]  = count
  end


  def sum_of_entries(started_on, stopped_on)
    debit  = self.entries.sum(:debit,  :select=>"entries.debit",  :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on])
    credit = self.entries.sum(:credit, :select=>"entries.credit", :joins=>"join journal_records as r on (entries.record_id=r.id)", :conditions=>["r.created_on BETWEEN ? AND ?", started_on, stopped_on])
    debit  = 0 if debit.nil?
    credit = 0 if credit.nil?
    for child in self.children
      d, c = child.sum(started_on, stopped_on)
      debit  += d
      credit += c
    end
    return debit, credit
  end
  
  
  def level
    if self.parent_id.nil?
      0
    else
      self.parent.level+1
    end
  end

  def letterable_entries
#    self.entries.find :all, :select=>"entries.*", :joins=>"JOIN accounts ON (entries.account_id=accounts.id) JOIN journal_records AS r ON (r.id=entries.record_id) JOIN journal_periods AS p ON (p.id=r.period_id)", :conditions=>"NOT p.closed AND accounts.letterable", :order=>:id
    self.all_entries "NOT journal_periods.closed AND NOT financialyears.closed AND accounts.letterable", :id
  end
  
  def next_neighbour
    Account.find :first, :conditions=>["number>? AND company_id=?",self.number, self.company_id], :order=>"number"
  end
  
  def previous_neighbour
    Account.find :first, :conditions=>["number<? AND company_id=?",self.number, self.company_id], :order=>"number desc"
  end
  
  def all_entries(conditions=nil, order=nil)
    self.entries.find :all, :select=>"entries.*", :joins=>"JOIN accounts ON (entries.account_id=accounts.id) JOIN journal_records ON (journal_records.id=entries.record_id) JOIN journal_periods ON (journal_periods.id=journal_records.period_id) JOIN financialyears ON (financialyears.id=journal_periods.financialyear_id)", :conditions=>conditions, :order=>order
  end
  

  def search_last_letter
    l = self.last_letter
    l = "A" if l.nil? or l.size<=0
    while Entry.find_by_account_id_and_letter(self.id, l)
      l.succ!
    end
    self.update_attribute(:last_letter,l)
    l
  end

  def letter(entries)
    raise Exception.new("The entries have to be in an Array of ID") unless entries.is_a? Array
    raise Exception.new("Two entries must be specified at least") unless entries.size>1
    entries = Entry.find entries
    debit  = 0
    credit = 0
    for entry in entries
      debit  += entry.debit || 0
      credit += entry.credit || 0
      raise Exception.new("The entries are already lettered") unless entry.letter.nil?
    end
    raise Exception.new("The entries have to be balanced") if debit!=credit
    l = search_last_letter
    for entry in entries
      entry.update_attribute(:letter,l)
    end
  end
  
  def unletter(entries)
    raise Exception.new("The entries have to be in an Array of ID") unless entries.is_a? Array
    entries = Entry.find entries
    for entry in entries
      l = entry.letter
      unless l.nil?
        all_lettered = Entry.find_all_by_account_id_and_letter(entry.account_id, l)
        for e in all_lettered
          e.update_attribute(:letter,nil)
        end
        self.update_attribute(:last_letter,l) if l.rjust(8)<self.last_letter.rjust(8)
      end
    end
  end
  
  

end
