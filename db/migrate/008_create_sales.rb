class CreateSales < ActiveRecord::Migration
  def self.up
  
    # EstimateNature
    create_table :estimate_natures do |t|
      t.column :code,             :string,  :limit=>16, :null=>false
      t.column :name,             :string,  :null=>false
      t.column :expiration_id,    :integer, :null=>false, :references=>:delays
      t.column :is_active,        :boolean, :null=>false, :default=>true
      t.column :payment_delay_id, :integer, :null=>false, :references=>:delays
      t.column :downpayment_rate, :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :note,             :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end    
  
    # Estimate
    create_table :estimates do |t|
      t.column :number,           :string,  :limit=>64, :null=>false
      t.column :nature_id,        :integer, :null=>false, :references=>:estimate_natures
      t.column :price,            :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :taxed_price,      :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :state,            :string,  :limit=>1, :null=>false, :default=>'O'
      t.column :expired_on,       :date,    :null=>false
      t.column :expiration_id,    :integer, :null=>false, :references=>:delays
      t.column :payment_delay_id, :integer, :null=>false, :references=>:delays
      t.column :has_downpayment,  :boolean, :null=>false, :default=>false
      t.column :downpayment_price,:decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :client_id,        :integer, :null=>false, :references=>:entities
      t.column :contact_id,       :integer, :null=>false, :references=>:entity_contact
      t.column :contact_version_id,  :integer, :null=>false, :references=>:entities_contact_version
      t.column :invoice_contact_id,  :integer, :null=>false, :references=>:entities_contact
      t.column :delivery_contact_id, :integer, :null=>false, :references=>:entities_contact
      t.column :object,           :string
      t.column :function_title,   :string
      t.column :introduction,     :text
      t.column :conclusion,       :text
      t.column :note,             :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
  
    # EstimateLine
    create_table :estimate_lines do |t|
      t.column :estimate_id,      :integer, :null=>false, :references=>:estimates
      t.column :product_id,       :integer, :null=>false, :references=>:products
      t.column :pricelist_id,     :integer, :null=>false, :references=>:pricelists
      t.column :price_id,         :integer, :null=>false, :references=>:pricelist_items
      t.column :price_version_id, :integer, :null=>false, :references=>:pricelist_item_versions
      t.column :number,           :integer, :null=>false
      t.column :quantity,         :decimal, :null=>false, :precision=>16, :scale=>2, :default=>1.0.to_d
      t.column :price,            :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :taxed_price,      :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      # From product
      t.column :code,             :string,  :limit=>32, :null=>false
      t.column :ean13,            :string,  :limit=>13
      t.column :catalog_name,     :string,  :null=>false
      t.column :catalog_description, :text
      t.column :description,      :text
      t.column :account_id,       :integer, :null=>false, :references=>:accounts, :on_delete=>:cascade, :on_update=>:cascade
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    
    # Invoice
    create_table :invoices do |t|
      t.column :number,           :string,  :limit=>64, :null=>false
      t.column :price,            :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :taxed_price,      :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :payment_delay_id, :integer, :null=>false, :references=>:delays
      t.column :payment_on,       :date,    :null=>false
      t.column :has_downpayment,  :boolean, :null=>false, :default=>false
      t.column :downpayment_price,:decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :client_id,        :integer, :null=>false, :references=>:entities
      t.column :contact_id,       :integer, :null=>false, :references=>:entity_contact
      t.column :contact_version_id,  :integer, :null=>false, :references=>:entities_contact_version
      t.column :delivery_contact_id,  :integer, :null=>false, :references=>:entities_contact
      t.column :delivery_contact_version_id, :integer, :null=>false, :references=>:entities_contact_version
      t.column :object,           :string
      t.column :function_title,   :string
      t.column :introduction,     :text
      t.column :conclusion,       :text
      t.column :note,             :text
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    
    # Delivery
    create_table :deliveries do |t|
      t.column :estimate_id,      :integer, :null=>false, :references=>:estimates
      t.column :invoice_id,       :integer, :null=>false, :references=>:invoices
      t.column :delivered_on,     :date,    :null=>false
      t.column :price,            :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :taxed_price,      :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
    
    # DeliveryLine
    create_table :delivery_lines do |t|
      t.column :delivery_id,      :integer, :null=>false, :references=>:deliveries
      t.column :estimate_line_id, :integer, :null=>false, :references=>:estimate_lines
      t.column :product_id,       :integer, :null=>false, :references=>:products
      t.column :pricelist_id,     :integer, :null=>false, :references=>:pricelists
      t.column :price_id,         :integer, :null=>false, :references=>:pricelist_items
      t.column :price_version_id, :integer, :null=>false, :references=>:pricelist_item_versions
      t.column :quantity,         :decimal, :null=>false, :precision=>16, :scale=>2, :default=>1.0.to_d
      t.column :price,            :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :taxed_price,      :decimal, :null=>false, :precision=>16, :scale=>2, :default=>0.0.to_d
      t.column :company_id,       :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:cascade
    end
  
  end

  def self.down
  end
end
