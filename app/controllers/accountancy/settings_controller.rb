class Accountancy::SettingsController < ApplicationController

  def index
  end

  auto_complete_for :bank_account, :bank, :name
  auto_complete_for :bank_account, :account, :label
  auto_complete_for :bank_account, :currency, :name
  auto_complete_for :bank_account, :journal, :name
#  auto_complete_for :journal, :type, :name

  controls :currency, :delay, :bank, :bank_account, :journal_nature
  
  def currency_activate
    if request.post?
      c = Currency.find_by_id params[:id]
      c.active = true
      c.save!
    end
      redirect_to :action=>:currency_list
  end
  
  def currency_deactivate
    if request.post?
      c = Currency.find_by_id params[:id]
      c.active = false
      c.save!
    end
    redirect_to :action=>:currency_list
  end
  
end
