class CreateEntities < ActiveRecord::Migration
  def self.up
    # EntityNature
    create_table :entity_natures do |t|
      t.column :name,             :string,  :null=>false
      t.column :active,           :boolean, :null=>false, :default=>true
      t.column :physical,         :boolean, :null=>false, :default=>false
      t.column :title,            :string,  :null=>false
      t.column :description,      :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entity_natures, :company_id
    add_index :entity_natures, [:name, :company_id], :unique=>true

    # Entity
    create_table :entities do |t|
      t.column :nature_id,        :integer, :null=>false, :references=>:entity_natures, :on_delete=>:restrict, :on_update=>:cascade
      t.column :language_id,      :integer, :null=>false, :references=>:languages, :on_delete=>:restrict, :on_update=>:cascade
      t.column :code,             :string,  :null=>false
      t.column :surname,          :string,  :null=>false
      t.column :first_name,       :string
      t.column :full_name,        :string,  :null=>false
      t.column :active,           :boolean, :null=>false, :default=>true
      t.column :born_on,          :date
      t.column :ean13,            :string, :limit=>13
      t.column :surname_soundex2, :string, :limit=>4
      t.column :web_site,         :string
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entities, :company_id
    add_index :entities, [:code, :company_id], :unique=>true
    add_index :entities, [:surname, :company_id]
    add_index :entities, [:first_name, :company_id]
    add_index :entities, [:surname_soundex2, :company_id]

    # EntityContactNature
    create_table :entity_contact_natures do |t|
      t.column :name,             :string,    :null=>false
      t.column :active,           :boolean,   :null=>false, :default=>true
      t.column :description,      :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entity_contact_natures, :company_id
    add_index :entity_contact_natures, [:name, :company_id], :unique=>true
  
    # EntityContactNorm
    create_table :entity_contact_norms do |t|
      t.column :name,             :string,    :null=>false
      t.column :reference,        :string
      t.column :preferred,        :boolean,   :null=>false, :default=>false
      t.column :rtl,              :boolean,   :null=>false, :default=>false
      t.column :align,            :string,    :null=>false, :default=>"left", :limit=>7
      t.column :company_id,       :integer,   :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entity_contact_norms, :company_id
    add_index :entity_contact_norms, [:name, :company_id], :unique=>true

    # EntityContactNormItem
    create_table :entity_contact_norm_items do |t|
      t.column :contact_norm_id,  :integer, :null=>false, :references=>:entity_contact_norms,  :on_delete=>:cascade, :on_update=>:cascade
      t.column :title,            :string,  :null=>false
      t.column :nature,           :string,  :null=>false, :default=>"content", :limit=>15
      t.column :maxlength,        :integer, :null=>false, :default=>38
      t.column :content,          :string
      t.column :left_nature,      :string,  :limit=>15
      t.column :left_value,       :string,  :limit=>63
      t.column :right_nature,     :string,  :default=>"space", :limit=>15
      t.column :right_value,      :string,  :limit=>63
      t.column :position,         :integer
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entity_contact_norm_items, :company_id
    add_index :entity_contact_norm_items, [:nature, :contact_norm_id, :company_id], :unique=>true
    add_index :entity_contact_norm_items, [:title, :contact_norm_id, :company_id],  :unique=>true

    # EntityContact
    create_table :entity_contacts do |t|
      t.column :entity_id,        :integer, :null=>false, :references=>:entities,  :on_delete=>:cascade, :on_update=>:cascade
      t.column :nature_id,        :integer, :null=>false, :references=>:entity_contact_natures
      t.column :norm_id,          :integer, :null=>false, :references=>:entity_contact_norms
      t.column :active,           :boolean, :null=>false, :default=>true
      t.column :closed_on,        :date
      t.column :line_2,           :string, :limit=>38
      t.column :line_3,           :string, :limit=>38
      t.column :line_4_number,    :string, :limit=>38
      t.column :line_4_street,    :string, :limit=>38
      t.column :line_5,           :string, :limit=>38
      t.column :line_6_code,      :string, :limit=>38
      t.column :line_6_city,      :string, :limit=>38
      t.column :phone,            :string, :limit=>32
      t.column :fax,              :string, :limit=>32
      t.column :mobile,           :string, :limit=>32
      t.column :email,            :string
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :entity_contacts, :company_id

    # EntityContactVersion
    create_table :entity_contact_versions do |t|
      t.column :contact_id,       :integer,   :null=>false, :references=>:entities,  :on_delete=>:cascade, :on_update=>:cascade
      t.column :installed_at,     :datetime
      t.column :abandoned_at,     :datetime
      t.column :ligne_2,          :string, :limit=>38
      t.column :ligne_3,          :string, :limit=>38
      t.column :ligne_4_number,   :string, :limit=>38
      t.column :ligne_4_street,   :string, :limit=>38
      t.column :ligne_5,          :string, :limit=>38
      t.column :ligne_6_code,     :string, :limit=>38
      t.column :ligne_6_city,     :string, :limit=>38
      t.column :phone,            :string, :limit=>32
      t.column :fax,              :string, :limit=>32
      t.column :mobile,           :string, :limit=>32
      t.column :email,            :string
    end
    add_index :entity_contact_versions, :contact_id

    # Data
    part = Part.create :name=>"relationship", :code=>Part::RELATIONSHIP, :image_url=>"part-relationship.png"
    component = PartComponent.create(:name=>"entity", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:search:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",      :component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",     :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",         :component_id=>component.id, :contextual=>true)
    
    component = PartComponent.create(:name=>"settings", :part_id=>part.id, :position=>2050)
    procedure = PartComponentProcedure.create(:name=>"index",:actions=>":index:", :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"nature",:actions=>":nature_list:nature_edit:nature_new:nature_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    PartComponentProcedure.create(:name=>"contact_norm",:actions=>":contact_norm_list:contact_norm_edit:contact_norm_new:contact_norm_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    PartComponentProcedure.create(:name=>"contact_nature",:actions=>":contact_nature_list:contact_nature_edit:contact_nature_new:contact_nature_destroy:", :component_id=>component.id, :parent_id=>procedure.id)
    
  end

  def self.down
    part = Part.find_by_code Part::RELATIONSHIP
    part.destroy if part

    drop_table :entity_contact_versions
    drop_table :entity_contacts
    drop_table :entity_contact_norm_items
    drop_table :entity_contact_norms
    drop_table :entity_contact_natures
    drop_table :entities
    drop_table :entity_natures
  end
end
