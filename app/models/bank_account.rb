# == Schema Information
# Schema version: 8
#
# Table name: bank_accounts
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  agency       :string(255)   
#  counter      :string(16)    
#  number       :string(32)    
#  key          :string(4)     
#  iban         :string(34)    not null
#  iban_text    :string(48)    not null
#  bic          :string(16)    
#  bank_id      :integer       not null
#  journal_id   :integer       not null
#  currency_id  :integer       not null
#  account_id   :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class BankAccount < ActiveRecord::Base

  def before_validation
    self.iban.upcase!
    self.iban.gsub!(/( |IBAN)/,"")
    self.iban_text = "IBAN EU00 1"
  end
  
  def validate
    unless self.iban.match /^[A-Z]{2}[0-9]{2}[0-9]*$/
      errors.add(:iban, "isn't valid. Ex : FR45 3000 3012 1296 1592 6312 3")
    end
  end
  
  def after_validation
    self.iban_text = "IBAN "+self.iban.split(/(\w\w\w\w)/).delete_if{|x| x.length<=0}.join(" ")
  end

end
