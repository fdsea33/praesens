# == Schema Information
# Schema version: 8
#
# Table name: companies
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  code         :string(8)     not null
#  admin        :boolean       not null
#  siren        :string(9)     default("000000000"), not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Company < ActiveRecord::Base
	ADMIN_NAME = "Administration"
	ADMIN_CODE = "ADMIN"
	
	has_one :accountancy

  def before_save
    if self.siren.nil?
      self.siren = "XXXXXXXXX"
    end
  end

  def after_save
    for e in self.establishments
      unless e.nil?
        e.note  = e.note.to_s
        e.save!
      end
    end
  end

  def after_create
    unless self.name==ADMIN_NAME
      language = Language.find_by_code 'fr'
      role = Role.create! :name=>Role::ADMINISTRATOR, :admin=>true, :company_id=>self.id
      login = default_login
      self.users.create! :name=>login[:name], :password=>login[:password], :password_confirmation=>login[:password], 
      :language_id=>language.id, :role_id=>role.id
      self.entity_natures.create! :name=>"Monsieur", :title=>"M.", :physical=>true, :description=>"Humain de sexe masculin marié ou célibataire"
      self.entity_natures.create! :name=>"Dame", :title=>"Mme", :physical=>true, :description=>"Humain de sexe féminin marié"
      self.entity_natures.create! :name=>"Demoiselle", :title=>"Mlle", :physical=>true, :description=>"Humain de sexe féminin non marié"
      self.entity_natures.create! :name=>"SARL", :title=>"S.A.R.L.", :description=>"Société Anonyme à Responsabilité Limitée"
      self.entity_contact_norms.create! :name=>"Norme française", :reference=>"AFNOR XP Z 10-011 (mai 1997)", :preferred=>true
      self.entity_contact_natures.create! :name=>"Domicile", :description=>"Lieu de résidence régulier et privé"
      self.entity_contact_natures.create! :name=>"Travail", :description=>"Lieu d'exécution du métier"
      c1 = self.currencies.create! :name=>"Euro", :code=>"EUR", :format=>"%n €"
      self.currencies.create! :name=>"Dollar (USA)", :code=>"USD", :format=>"$%n", :rate=>0.708
      self.currencies.create! :name=>"Livre sterling", :code=>"GBP", :format=>"£%n", :rate=>1.429
      self.delays.create! :name=>"Immédiat", :active=>true
      self.delays.create! :name=>"90 jours", :active=>true, :days=>90
      self.delays.create! :name=>"30 jours fin de mois", :active=>true, :days=>30, :end_of_month=>true
      self.delays.create! :name=>"10 jours fin de mois le 15", :active=>true, :days=>10, :end_of_month=>true, :additional_days=>15
      self.accounts.create! :number=>"1", :name=>"Comptes de capitaux", :transferable=>true
      self.accounts.create! :number=>"101", :name=>"Capital"
      self.accounts.create! :number=>"1011", :name=>"Capital souscrit - non appelé"
      self.accounts.create! :number=>"1012", :name=>"Capital souscrit - appelé, non versé"
      self.accounts.create! :number=>"1013", :name=>"Capital souscrit - appelé, versé"
      self.accounts.create! :number=>"10", :name=>"Capital et réserves"
      self.accounts.create! :number=>"11", :name=>"Report à nouveau (solde créditeur ou débiteur)"
      a110 = self.accounts.create! :number=>"110", :name=>"Report à nouveau (solde créditeur)"
      a119 = self.accounts.create! :number=>"119", :name=>"Report à nouveau (solde débiteur)"
      self.accounts.create! :number=>"12", :name=>"Résultat de l'exercice (bénéfice ou perte)"
      a120 = self.accounts.create! :number=>"120", :name=>"Résultat de l'exercice (bénéfice)" 
      a129 = self.accounts.create! :number=>"129", :name=>"Résultat de l'exercice (perte)" 
      self.accounts.create! :number=>"2", :name=>"Comptes d'immobilisations", :transferable=>true
      self.accounts.create! :number=>"3", :name=>"Comptes de stocks et en-cours", :transferable=>true
      self.accounts.create! :number=>"4", :name=>"Comptes de tiers", :transferable=>true
      self.accounts.create! :number=>"40", :name=>"Fournisseurs et comptes rattachés"
      self.accounts.create! :number=>"401", :name=>"Fournisseurs"
      self.accounts.create! :number=>"4011", :name=>"Fournisseurs - Achats de biens et prestations de services"
      self.accounts.create! :number=>"41", :name=>"Clients et comptes rattachés"
      self.accounts.create! :number=>"411", :name=>"Clients" 
      self.accounts.create! :number=>"4111", :name=>"Clients - Ventes de biens ou de prestations de services"
      self.accounts.create! :number=>"44", :name=>"État et autres collectivités publiques"
      self.accounts.create! :number=>"445", :name=>"Etat - Taxes sur le chiffre d'affaires"
      self.accounts.create! :number=>"4457", :name=>"Taxes sur le chiffre d'affaires collectées par l'entreprise"
      self.accounts.create! :number=>"44571", :name=>"T.V.A. collectée"
      self.accounts.create! :number=>"4457104", :name=>"T.V.A. collectée 19,6%"
      self.accounts.create! :number=>"4457110", :name=>"T.V.A. collectée 5,5%"
      self.accounts.create! :number=>"5", :name=>"Comptes financiers", :transferable=>true
      self.accounts.create! :number=>"51", :name=>"Banques, établissements financiers et assimilés"
      self.accounts.create! :number=>"512", :name=>"Banques"
      self.accounts.create! :number=>"5121", :name=>"Comptes en monnaie nationale"
      self.accounts.create! :number=>"5124", :name=>"Comptes en devises"
      self.accounts.create! :number=>"6", :name=>"Comptes de charges"
      self.accounts.create! :number=>"60", :name=>"Achats (sauf 603)"
      self.accounts.create! :number=>"606", :name=>"Achats non stockés de matière et fournitures"
      self.accounts.create! :number=>"6064", :name=>"Fournitures administratives"
      self.accounts.create! :number=>"607", :name=>"Achats de marchandises"
      self.accounts.create! :number=>"6071", :name=>"Marchandise (ou groupe) A"
      self.accounts.create! :number=>"6072", :name=>"Marchandise (ou groupe) B"
      self.accounts.create! :number=>"7", :name=>"Comptes de produits"
      self.accounts.create! :number=>"70", :name=>"Ventes de produits fabriqués, prestations de services, marchandises"
      self.accounts.create! :number=>"707", :name=>"Ventes de marchandises"
      self.accounts.create! :number=>"7071", :name=>"Marchandises (ou groupe) A"
      self.accounts.create! :number=>"7072", :name=>"Marchandises (ou groupe) B"
      self.accounts.create! :number=>"8", :name=>"Comptes spéciaux" 
      self.banks.create! :name=>"Société Générale", :code=>"30003"
      self.banks.create! :name=>"BNP Paribas", :code=>"25631"
      self.banks.create! :name=>"AXA Banque", :code=>"12545"
      self.banks.create! :name=>"Banque Accord", :code=>"45231"
      self.banks.create! :name=>"LCL", :code=>"85236"
      self.banks.create! :name=>"Banque Populaire", :code=>"21351"
      self.banks.create! :name=>"Banque postale", :code=>"15646"
      self.banks.create! :name=>"CIC", :code=>"15654"
      self.banks.create! :name=>"Groupama Banque", :code=>"16514"
      self.banks.create! :name=>"Dexia", :code=>"14782"
      tj1 = self.journal_natures.create! :name=>"Ventes"
      tj2 = self.journal_natures.create! :name=>"Achats"
      tj3 = self.journal_natures.create! :name=>"Opérations diverses"
      tj4 = self.journal_natures.create! :name=>"Trésorerie"
      j1 = self.journals.create! :nature_id=>tj1.id, :name=>"Ventes (tous types)", :code=>"VT"
      j2 = self.journals.create! :nature_id=>tj2.id, :name=>"Achats (tous types)", :code=>"AC"
      self.journals.create! :nature_id=>tj3.id, :name=>"O.D.",   :code=>"OD"
      j4 = self.journals.create! :nature_id=>tj3.id, :name=>"À Nouveau",   :code=>"AN"
      self.journals.create! :nature_id=>tj4.id, :name=>"Banque", :code=>"BQ"
      self.journals.create! :nature_id=>tj4.id, :name=>"Caisse", :code=>"CS"
      fyt = self.financialyear_natures.create! :name=>"Exercice fiscal", :code=>"EF", :fiscal=>true
      self.create_accountancy :name=>"Comptabilité", :currency_id=>c1.id, :newyear_id=>j4.id, :sales_id=>j1.id, :purchases_id=>j2.id, :losses_id=>a129.id, :profits_id=>a120.id, :master_nature_id=>fyt.id, :report_credit_id=>a110.id, :report_debit_id=>a119.id
    end
  end
  
  def default_login
    {:name=>self.code.downcase+"_admin", :password=>self.code.downcase+(self.code.length*7).to_s}
  end
  
  def allowed_journals
    self.journals.find(:all)
#    self.journals.find(:all, :conditions=>["closed_on<?", Date.today])
  end
  
  def allowed_currencies
    self.currencies.find(:all, :conditions=>{:active=>true})
  end
  
  def current_financialyear
    self.accountancy.master_nature.current_financialyear
  end
  
  def first_financialyear
    self.accountancy.master_nature.financialyears.find(:first, :order=>"started_on")
  end
  
  def balance(started_on, stopped_on=nil)
    return nil if started_on.nil?
    stopped_on = started_on >> 12 if stopped_on.nil?
    account = self.accounts.find(:first,:conditions=>"parent_id=0")
    balance = {}
    account.compute(balance, started_on, stopped_on)
    balance
  end
  
  def all_entries(conditions=nil, order=nil)
    self.entries.find :all, :select=>"entries.*", :joins=>"JOIN accounts ON (entries.account_id=accounts.id) JOIN journal_records ON (journal_records.id=entries.record_id) JOIN journal_periods ON (journal_periods.id=journal_records.period_id) JOIN financialyears ON (financialyears.id=journal_periods.financialyear_id)", :conditions=>conditions, :order=>order
  end
  


end
