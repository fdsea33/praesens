# == Schema Information
# Schema version: 9
#
# Table name: entries
#
#  id               :integer       not null, primary key
#  record_id        :integer       not null
#  account_id       :integer       not null
#  name             :string(255)   not null
#  currency_debit   :decimal(16, 2 default(0.0), not null
#  currency_credit  :decimal(16, 2 default(0.0), not null
#  currency_rate_id :integer       not null
#  currency_id      :integer       not null
#  debit            :decimal(16, 2 default(0.0), not null
#  credit           :decimal(16, 2 default(0.0), not null
#  intermediate_id  :integer       
#  statement_id     :integer       
#  letter           :string(8)     
#  expired_on       :date          
#  position         :integer       
#  comment          :text          
#  company_id       :integer       not null
#  created_at       :datetime      
#  created_by       :integer       
#  updated_at       :datetime      
#  updated_by       :integer       
#  lock_version     :integer       default(0), not null
#

require 'bigdecimal/math'
include BigMath

class Entry < ActiveRecord::Base
  validates_constancy_of :record_id, :account_id, :currency_debit, :currency_credit, :currency_rate_id, :currency_id, :debit, :credit, :name
  acts_as_list :scope=>:record_id
  attr_accessor :to_letter

  def initialize(*params)
    super(*params)
    if (@new_record)
      self.currency_id = self.company.accountancy.currency_id if self.currency_id.nil? and !self.company_id.nil?
    end
  end


  def before_validation_on_create
    self.currency_debit=0  if self.currency_debit.nil?
    self.currency_credit=0 if self.currency_credit.nil?
    unless self.currency_id.nil?
      self.currency_rate_id = self.currency.current_rate.id if self.currency_rate_id.nil? or (self.currency_rate.currency_id!=self.currency_id)
      rate = self.currency_rate.rate
      self.debit  = (self.currency_debit*rate).round(2)
      self.credit = (self.currency_credit*rate).round(2)
    end
    self.company_id = self.record.company_id if self.record
  end

  def validate
    unless (debit==0 and credit>0) or (debit>0 and credit==0)
      errors.add_to_base("Debit and credit aren't valid")
    end
  end

  def after_save
    self.record.refresh
  end
  
  def before_destroy
    # Vérifie que l'écriture est destructible (ne se trouve pas dans une période close)
    
  end

  def letter_color
    if self.letter
      color = Digest::MD5.hexdigest(self.letter)
      "#"+light(color[0..1])+light(color[2..3])+light(color[4..5],210)
    else
     "#ffffff"
    end
  end  
  
  private
  
  def light(canal, base=200, factor=0.15)
    (base+(canal.to_s.to_i(16)*factor)).round.to_s(16)
  end
  
end
