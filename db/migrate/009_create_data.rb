class CreateData < ActiveRecord::Migration
  def self.up
    language = Language.find_by_code 'fr'
    company = Company.create(:name=>Company::ADMIN_NAME, :code=>Company::ADMIN_CODE, :admin=>true)
    role = company.roles.create :name=>Role::ADMINISTRATOR, :admin=>true
    company.users.create :name=>User::ADMIN, :password=>User::ADMIN, :password_confirmation=>User::ADMIN, :language_id=>language.id, :role_id=>role.id


    # Test data
    company = Company.create(:name=>"FDSEA 33", :code=>"FDSEA", :siren=>"090190941")

    company = Company.create(:name=>"Test company", :code=>"TEST", :siren=>"157852639")
    role = company.roles.create :name=>Role::PUBLIC
    role.recover_all_rights
    for right in role.rights
      if right.part.code==Part::RELATIONSHIP or right.procedure.name == "select"
        right.active = true
        right.save!
      end
    end
    company.users.create(:name=>"roger", :password=>"roger", :password_confirmation=>"roger", :language_id=>language.id, :role_id=>role.id)
    e1 = company.establishments.create(:name=>"Siège", :nic=>"08502")
    e2 = company.establishments.create(:name=>"Usine A", :nic=>"08585")
    e3 = company.establishments.create(:name=>"Usine B", :nic=>"13285")
    
    s1 = company.departments.create(:name=>"Général",:company_establishment_id=>e1.id)
    s2 = company.departments.create(:name=>"Informatique",:company_establishment_id=>e1.id, :parent_id=>s1.id)
    s3 = company.departments.create(:name=>"Production A",:company_establishment_id=>e2.id, :parent_id=>s1.id)
    s4 = company.departments.create(:name=>"Production A'",:company_establishment_id=>e3.id, :parent_id=>s3.id)

    company = Company.create(:name=>"Service d'Aide et de Conseil aux Expl. Agri. (Gironde)", :code=>"SACEA", :siren=>"085101550")
    company = Company.create(:name=>"Avenir Agricole & Viticole Aquitain", :code=>"AAVA", :siren=>"098640941")


  end
  
  def self.down
    CompanyDepartment.delete_all
    CompanyEstablishment.delete_all
    Accountancy.delete_all
    BankAccount.delete_all
    Entry.delete_all
    JournalRecord.delete_all
    JournalPeriod.delete_all
    Journal.delete_all
    AccountBalance.delete_all
    Financialyear.delete_all

    CurrencyVersion.update_all("created_by=NULL, updated_by=NULL")
    Currency.update_all("created_by=NULL, updated_by=NULL")
    Delay.update_all("created_by=NULL, updated_by=NULL")
    FinancialyearNature.update_all("created_by=NULL, updated_by=NULL")
    JournalNature.update_all("created_by=NULL, updated_by=NULL")
    BankAccount.update_all("created_by=NULL, updated_by=NULL")
    Bank.update_all("created_by=NULL, updated_by=NULL")
    Account.update_all("created_by=NULL, updated_by=NULL, entity_id=NULL")
    Role.update_all("created_by=NULL, updated_by=NULL")
    Entity.update_all("created_by=NULL, updated_by=NULL")
    EntityNature.update_all("created_by=NULL, updated_by=NULL")
    Company.update_all("created_by=NULL, updated_by=NULL")
    
    User.delete_all
    Role.delete_all
    Entity.delete_all
    EntityNature.delete_all
    Account.delete_all
    Company.delete_all   
  end
  
end
