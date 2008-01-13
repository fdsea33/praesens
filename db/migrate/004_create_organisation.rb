class CreateOrganisation < ActiveRecord::Migration
  def self.up
    # CompanyEstablishment
    create_table :company_establishments do |t|
      t.column :name,  :string, :null=>false
      t.column :nic,   :string, :null=>false, :limit=>5
      t.column :siret, :string, :null=>false
      t.column :address, :text
      t.column :note, :text
      t.column :company_id, :integer, :null=>false, :references=>:companies, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :company_establishments, [:name,  :company_id], :unique=>true
    add_index :company_establishments, [:siret, :company_id], :unique=>true

    # CompanyDepartment
    create_table :company_departments do |t|
      t.column :name, :string, :null=>false
      t.column :parent_id, :integer, :references=>:company_departments, :on_delete=>:restrict, :on_update=>:restrict
      t.column :company_establishment_id, :integer, :null=>false, :references=>:company_establishments, :on_delete=>:restrict, :on_update=>:restrict
      t.column :company_id, :integer, :null=>false, :references=>:companies, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :company_departments, [:name, :company_id], :unique=>true
    add_index :company_departments, :parent_id

    # CompanyEmployee
    create_table :company_employees do |t|
      t.column :company_department_id, :integer, :null=>false, :references=>:company_departments, :on_delete=>:restrict, :on_update=>:restrict
      t.column :user_id,               :integer, :references=>:users, :on_delete=>:restrict, :on_update=>:restrict
			t.column :title,                 :string,  :null=>false, :limit=>32
			t.column :surname,               :string,  :null=>false
			t.column :first_name,            :string,  :null=>false
      t.column :arrived_on,            :date,    :null=>false
			t.column :role,                  :string
			t.column :phone,                 :string, :limit=>32
			t.column :email,                 :string
			t.column :mobile,                :string, :limit=>32
			t.column :fax,                   :string, :limit=>32
			t.column :office,                :string, :limit=>32
			t.column :note,                  :text
      t.column :company_id,            :integer, :null=>false, :references=>:companies, :on_delete=>:restrict, :on_update=>:restrict
    end
    add_index :company_employees, [:company_id, :user_id], :unique=>true

		part = Part.find_by_code(Part::ORGANISATION)
		component = PartComponent.create(:name=>"establishment", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",      :component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",     :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",         :component_id=>component.id, :contextual=>true)
		component = PartComponent.create(:name=>"department", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",      :component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",     :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",         :component_id=>component.id, :contextual=>true)
		component = PartComponent.create(:name=>"employee", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",      :component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",     :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",         :component_id=>component.id, :contextual=>true)

  end

  def self.down
    drop_table :company_employees
    drop_table :company_departments
    drop_table :company_establishments
  end
end
