class CreateInternationalization < ActiveRecord::Migration
  def self.up
    # Language
    create_table :languages do |t|
      t.column :code,   :string,  :null=>false
      t.column :active, :boolean, :null=>false, :default=>false
    end
		add_index :languages, :code, :unique=>true

    # User
    add_column :users, :language_id, :integer, :null=>false, :references=>:languages, :on_delete=>:restrict, :on_update=>:restrict

    # Data
    Language.create :code=>"fr"
    Language.create :code=>"en"
    Language.create :code=>"es"
    Language.create :code=>"de"
    Language.create :code=>"nl"

  end

  def self.down
    drop_table :languages
  end
end
