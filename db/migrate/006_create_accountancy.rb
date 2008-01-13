  class CreateAccountancy < ActiveRecord::Migration
  def self.up
    # Currency
    create_table :currencies do |t|
      t.column :name,             :string,   :null=>false
      t.column :code,             :string,   :null=>false
      t.column :format,           :string,   :null=>false, :limit=>16
      t.column :rate,             :decimal,  :null=>false, :precision=>16, :scale=>6, :default=>1
      t.column :active,           :boolean,  :null=>false, :default=>true
      t.column :comment,          :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
		add_index :currencies, :company_id
		add_index :currencies, :active
		add_index :currencies, [:code, :company_id], :unique=>true
		add_index :currencies, :name
		
    # CurrencyVersion
    create_table :currency_versions do |t|
      t.column :format,           :string,   :null=>false, :limit=>16
      t.column :rate,             :decimal,  :null=>false, :precision=>16, :scale=>6, :default=>1
      t.column :started_at,       :datetime, :null=>false, :default=>Time.at(0)
      t.column :stopped_at,       :datetime
      t.column :currency_id,      :integer,  :null=>false, :references=>:currencies, :on_delete=>:cascade, :on_update=>:cascade
      t.column :company_id,       :integer,  :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
		add_index :currency_versions, :company_id
		add_index :currency_versions, :currency_id
		
		
    # Delay : Délais
    create_table :delays do |t|
      t.column :name,             :string,  :null=>false
      t.column :active,           :boolean, :null=>false, :default=>false
      t.column :months,           :integer, :null=>false, :default=>0
      t.column :days,             :integer, :null=>false, :default=>0
      t.column :end_of_month,     :boolean, :null=>false, :default=>false
      t.column :additional_days,  :integer, :null=>false, :default=>0
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :delays, [:name, :company_id], :unique=>true
  
    # Account : Comptes comptables
    create_table :accounts do |t|
      t.column :number,           :string,  :null=>false, :limit=>16
      t.column :alpha,            :string,  :limit=>16
      t.column :name,             :string,  :null=>false, :limit=>208
      t.column :label,            :string,  :null=>false
      t.column :usable,           :boolean, :null=>false, :default=>false
      t.column :groupable,        :boolean, :null=>false, :default=>false
      t.column :keep_entries,     :boolean, :null=>false, :default=>false
      t.column :transferable,     :boolean, :null=>false, :default=>false
      t.column :letterable,       :boolean, :null=>false, :default=>false
      t.column :pointable,        :boolean, :null=>false, :default=>false
      t.column :is_debit,         :boolean, :null=>false, :default=>false
      t.column :last_letter,      :string,  :limit=>8
      t.column :comment,          :text
      t.column :delay_id,      :integer, :references=>:delays, :on_delete=>:restrict, :on_update=>:cascade
      t.column :entity_id,        :integer, :references=>:entities, :on_delete=>:restrict, :on_update=>:cascade
      t.column :parent_id,        :integer, :null=>false, :references=>nil
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :accounts, [:number, :company_id], :unique=>true
    add_index :accounts, [:label, :company_id], :unique=>true
    add_index :accounts, [:alpha, :company_id], :unique=>true
    add_index :accounts, [:name, :company_id]
    add_index :accounts, [:entity_id, :company_id]
    add_index :accounts, [:delay_id]
    add_index :accounts, [:entity_id]
    add_index :accounts, [:parent_id]
    add_index :accounts, [:company_id]

    # FinancialyearNature : Type d'exercice comptable
    create_table :financialyear_natures do |t|
      t.column :name,             :string,  :null=>false
      t.column :code,             :string,  :null=>false, :limit=>2
      t.column :fiscal,           :boolean, :null=>false, :default=>false
      t.column :month_number,     :integer, :null=>false, :default=>12
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :financialyear_natures, [:name, :company_id], :unique=>true
    add_index :financialyear_natures, [:code, :company_id], :unique=>true
    add_index :financialyear_natures, [:fiscal, :company_id]
    add_index :financialyear_natures, :company_id

    # Financialyear : Exercice comptable
    create_table :financialyears do |t|
      t.column :code,             :string,  :null=>false, :limit=>12
      t.column :nature_id,        :integer, :null=>false, :references=>:financialyear_natures
      t.column :closed,           :boolean, :null=>false, :default=>false
      t.column :started_on,       :date,    :null=>false
      t.column :stopped_on,       :date,    :null=>false
      t.column :written_on,       :date,    :null=>false # Date butoir de création des journaux
      t.column :debit,            :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :credit,           :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :position,         :integer, :null=>false
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :financialyears, [:code, :company_id], :unique=>true
    add_index :financialyears, [:nature_id, :company_id]
    add_index :financialyears, :company_id

    # AccountBalance : Historique des soldes des comptes par exercice
    create_table :account_balances do |t|
      t.column :account_id,       :integer, :null=>false, :references=>:accounts,       :on_delete=>:restrict, :on_update=>:cascade
      t.column :financialyear_id, :integer, :null=>false, :references=>:financialyears, :on_delete=>:restrict, :on_update=>:cascade
#      t.column :year,             :integer, :null=>false, :default=>1
#      t.column :month,            :integer, :null=>false, :default=>0
      t.column :global_debit,     :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :global_credit,    :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :global_balance,   :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :global_count,     :integer, :null=>false, :default=>0
      t.column :local_debit,      :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :local_credit,     :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :local_balance,    :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :local_count,      :integer, :null=>false, :default=>0
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :account_balances, :company_id
    add_index :account_balances, :financialyear_id
#    add_index :account_balances, [:month, :company_id]
    add_index :account_balances, [:account_id, :financialyear_id, :company_id], :unique=>true

    # JournalNature : Type de journal
    create_table :journal_natures do |t|
      t.column :name,             :string,  :null=>false
      t.column :comment,          :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :journal_natures, :company_id
    add_index :journal_natures, [:name, :company_id], :unique=>true

    # Journal : Journal
    create_table :journals do |t|
      t.column :nature_id,          :integer, :null=>false, :references=>:journal_natures, :on_delete=>:restrict, :on_update=>:cascade
      t.column :name,             :string,  :null=>false
      t.column :code,             :string,  :null=>false, :limit=>4
      t.column :counterpart_id,   :integer, :references=>:accounts, :on_delete=>:cascade, :on_update=>:cascade
      t.column :closed_on,        :date,    :null=>false, :default=>Date.civil(1494,12,31)
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :journals, :company_id
    add_index :journals, :nature_id
    add_index :journals, [:name, :company_id], :unique=>true
    add_index :journals, [:code, :company_id], :unique=>true

    # JournalPeriod : Période de journal
    create_table :journal_periods do |t|
      t.column :journal_id,       :integer, :null=>false, :references=>:journals, :on_delete=>:restrict, :on_update=>:cascade
      t.column :financialyear_id, :integer, :null=>false, :references=>:financialyears, :on_delete=>:restrict, :on_update=>:cascade
      t.column :started_on,       :date,    :null=>false
      t.column :stopped_on,       :date,    :null=>false
      t.column :closed,           :boolean, :default=>false
      t.column :debit,            :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :credit,           :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :balance,          :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :journal_periods, :company_id
    add_index :journal_periods, :journal_id
    add_index :journal_periods, :financialyear_id
    add_index :journal_periods, :started_on
    add_index :journal_periods, :stopped_on
    add_index :journal_periods, [:started_on, :journal_id], :unique=>true
    add_index :journal_periods, [:stopped_on, :journal_id], :unique=>true

    # JournalRecord : Piece comptable
    create_table :journal_records do |t|
      t.column :created_on,       :date,    :null=>false
      t.column :printed_on,       :date,    :null=>false
      t.column :number,           :integer, :null=>false
      t.column :status,           :string,  :null=>false, :default=>"A", :limit=>1
      t.column :debit,            :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :credit,           :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :balance,          :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :position,         :integer, :null=>false
      t.column :period_id,        :integer, :null=>false, :references=>:journal_periods, :on_delete=>:restrict, :on_update=>:cascade
      t.column :journal_id,       :integer, :null=>false, :references=>:journals,  :on_delete=>:restrict, :on_update=>:cascade
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :journal_records, [:status, :company_id]
    add_index :journal_records, [:created_on, :company_id]
    add_index :journal_records, [:printed_on, :company_id]
    add_index :journal_records, :journal_id
    add_index :journal_records, :period_id
    add_index :journal_records, :company_id

    # Bank : Banques
    create_table :banks do |t|
      t.column :name,             :string,  :null=>false
      t.column :code,             :string,  :null=>false, :limit=>16
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :banks, [:name, :company_id], :unique=>true
    add_index :banks, [:code, :company_id], :unique=>true
    add_index :banks, :company_id
    
    # BankAccount : Comptes bancaires
    create_table :bank_accounts do |t|
      t.column :name,             :string,  :null=>false
      t.column :agency,           :string
      t.column :counter,          :string, :limit=>16
      t.column :number,           :string, :limit=>32
      t.column :key,              :string, :limit=>4
      t.column :iban,             :string,  :null=>false, :limit=>34
      t.column :iban_text,        :string,  :null=>false, :limit=>48
      t.column :bic,              :string,  :limit=>16
      t.column :bank_id,          :integer, :null=>false, :references=>:banks,      :on_delete=>:cascade, :on_update=>:cascade
      t.column :journal_id,       :integer, :null=>false, :references=>:journals,   :on_delete=>:restrict, :on_update=>:cascade
      t.column :currency_id,      :integer, :null=>false, :references=>:currencies, :on_delete=>:cascade, :on_update=>:cascade
      t.column :account_id,       :integer, :null=>false, :references=>:accounts,   :on_delete=>:cascade, :on_update=>:cascade
      t.column :company_id,       :integer, :null=>false, :references=>:companies,  :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :bank_accounts, [:name, :bank_id, :account_id], :unique=>true
    add_index :bank_accounts, :bank_id
    add_index :bank_accounts, :journal_id
    add_index :bank_accounts, :currency_id
    add_index :bank_accounts, :account_id
    add_index :bank_accounts, :company_id
    add_index :bank_accounts, [:bank_id, :account_id], :unique=>true

    # BankAccountStatement : Relevé de compte
    create_table :bank_account_statements do |t|
      t.column :bank_account_id,  :integer, :null=>false, :references=>:bank_accounts, :on_delete=>:cascade, :on_update=>:cascade
      t.column :started_on,       :date,    :null=>false
      t.column :stopped_on,       :date,    :null=>false
      t.column :printed_on,       :date,    :null=>false
      t.column :intermediate,     :boolean, :null=>false, :default=>false
      t.column :number,           :string,  :null=>false
      t.column :debit,            :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :credit,           :decimal, :null=>false, :default=>0, :precision=>16, :scale=>2
      t.column :company_id,       :integer, :null=>false, :references=>:companies,  :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :bank_account_statements, :bank_account_id
    add_index :bank_account_statements, :company_id
    
    
    # Entry : Écriture comptable
    create_table :entries do |t|
      t.column :record_id,        :integer, :null=>false, :references=>:journal_records, :on_delete=>:restrict, :on_update=>:cascade
      t.column :account_id,       :integer, :null=>false, :references=>:accounts, :on_delete=>:restrict, :on_update=>:cascade
      t.column :name,             :string,  :null=>false
      t.column :currency_debit,   :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0
      t.column :currency_credit,  :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0
      t.column :currency_version_id, :integer, :null=>false, :references=>:currency_versions, :on_delete=>:restrict, :on_update=>:cascade
      t.column :currency_id,      :integer, :null=>false, :references=>:currencies, :on_delete=>:restrict, :on_update=>:cascade
      t.column :debit,            :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0
      t.column :credit,           :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0
      t.column :intermediate_id,  :integer, :references=>:bank_account_statements, :on_delete=>:restrict, :on_update=>:cascade
      t.column :statement_id,     :integer, :references=>:bank_account_statements, :on_delete=>:restrict, :on_update=>:cascade
      t.column :letter,           :string,  :limit=>8
      t.column :expired_on,       :date
      t.column :position,         :integer
      t.column :comment,          :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entries, :company_id
    add_index :entries, :record_id
    add_index :entries, :account_id
    add_index :entries, :statement_id
    add_index :entries, :intermediate_id
    add_index :entries, :name
    add_index :entries, :letter

    # Accountancy : Comptabilité (Paramètres généraux)
    create_table :accountancies do |t|
      t.column :name,             :string
      t.column :comment,          :text
      t.column :master_nature_id, :integer, :null=>false, :references=>:financialyear_natures, :on_delete=>:restrict, :on_update=>:cascade
      t.column :currency_id,      :integer, :null=>false, :references=>:currencies, :on_delete=>:restrict, :on_update=>:cascade
      t.column :report_credit_id, :integer, :null=>false, :references=>:accounts,   :on_delete=>:restrict, :on_update=>:cascade # Compte Report (C)
      t.column :report_debit_id,  :integer, :null=>false, :references=>:accounts,   :on_delete=>:restrict, :on_update=>:cascade # Compte Report (D)
      t.column :profits_id,       :integer, :null=>false, :references=>:accounts,   :on_delete=>:restrict, :on_update=>:cascade # Compte Bénéfice
      t.column :losses_id,        :integer, :null=>false, :references=>:accounts,   :on_delete=>:restrict, :on_update=>:cascade # Compte Perte
      t.column :sales_id,         :integer, :null=>false, :references=>:journals,   :on_delete=>:restrict, :on_update=>:cascade # Journal des ventes
      t.column :purchases_id,     :integer, :null=>false, :references=>:journals,   :on_delete=>:restrict, :on_update=>:cascade # Journal des achats
      t.column :newyear_id,       :integer, :null=>false, :references=>:journals,   :on_delete=>:restrict, :on_update=>:cascade # Journal des à nouveaux
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :accountancies, :company_id, :unique=>true



    # Data
    part = Part.create :name=>"accountancy", :code=>Part::ACCOUNTANCY, :image_url=>"part-accountancy.png"
    component = PartComponent.create(:name=>"accounts", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:search:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",     :component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",    :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",        :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"check", :actions=>":check:",          :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"letter",:actions=>":letter:",         :component_id=>component.id, :contextual=>true)

    component = PartComponent.create(:name=>"operations", :part_id=>part.id)
    procedure = PartComponentProcedure.create(:name=>"financialyear", :actions=>":financialyear_list:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"financialyear_edit", :actions=>":financialyear_edit:", :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"financialyear_open", :actions=>":financialyear_open:", :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"financialyear_close", :actions=>":financialyear_close:", :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    procedure = PartComponentProcedure.create(:name=>"journal",  :actions=>":journal_list:journal_show:",  :component_id=>component.id)
#    PartComponentProcedure.create(:name=>"journal_history",  :actions=>":journal_history:",  :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"journal_edit",  :actions=>":journal_edit:",  :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"journal_new",   :actions=>":journal_new:",  :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"journal_open",  :actions=>":journal_open:",  :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"journal_close", :actions=>":journal_close:", :component_id=>component.id, :parent_id=>procedure.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"record_entries",  :actions=>":select_journal_for_entries:record_entries:create_entry:",  :component_id=>component.id)

    component = PartComponent.create(:name=>"settings", :part_id=>part.id)
    procedure = PartComponentProcedure.create(:name=>"index",:actions=>":index:", :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"currency", :actions=>":currency_list:currency_new,:currency_edit:currency_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    PartComponentProcedure.create(:name=>"delay", :actions=>":delay_list:delay_new,:delay_edit:delay_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
#    PartComponentProcedure.create(:name=>"financialyear_nature", :actions=>":financialyear_nature_list:financialyear_nature_new,:financialyear_nature_edit:financialyear_nature_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    PartComponentProcedure.create(:name=>"journal_nature", :actions=>":journal_nature_list:journal_nature_new,:journal_nature_edit:journal_nature_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    PartComponentProcedure.create(:name=>"bank",  :actions=>":bank_list:bank_new,:bank_edit:bank_destroy:",     :component_id=>component.id, :parent_id=>procedure.id)
#    PartComponentProcedure.create(:name=>"journal", :actions=>":journal_list:journal_new,:journal_edit:journal_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    PartComponentProcedure.create(:name=>"bank_account", :actions=>":bank_account_list:bank_account_new,:bank_account_edit:bank_account_destroy:", :component_id=>component.id, :parent_id=>procedure.id)


  end

  def self.down
    Part.find_by_code(Part::ACCOUNTANCY).destroy
    
    drop_table :entries                         #
    drop_table :bank_account_statements         #
    drop_table :bank_accounts                   #
    drop_table :banks                           #
    drop_table :journal_records                 #
    drop_table :journal_periods                 #
    drop_table :journals                        #
    drop_table :journal_natures                   #
    drop_table :financialyears                  #
    drop_table :financialyear_natures             #
    drop_table :account_balances                #
    drop_table :accounts                        #
    drop_table :accountancies                   #
    drop_table :delays                       #
    drop_table :currency_versions                  #
    drop_table :currencies                      #
  end
end
