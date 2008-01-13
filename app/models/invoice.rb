# == Schema Information
# Schema version: 8
#
# Table name: invoices
#
#  id                          :integer       not null, primary key
#  number                      :string(64)    not null
#  price                       :decimal(16, 2 default(0.0), not null
#  taxed_price                 :decimal(16, 2 default(0.0), not null
#  payment_delay_id            :integer       not null
#  payment_on                  :date          not null
#  has_downpayment             :boolean       not null
#  downpayment_price           :decimal(16, 2 default(0.0), not null
#  client_id                   :integer       not null
#  contact_id                  :integer       not null
#  contact_version_id          :integer       not null
#  delivery_contact_id         :integer       not null
#  delivery_contact_version_id :integer       not null
#  object                      :string(255)   
#  function_title              :string(255)   
#  introduction                :text          
#  conclusion                  :text          
#  note                        :text          
#  company_id                  :integer       not null
#  created_at                  :datetime      
#  created_by                  :integer       
#  updated_at                  :datetime      
#  updated_by                  :integer       
#  lock_version                :integer       default(0), not null
#

class Invoice < ActiveRecord::Base
end
