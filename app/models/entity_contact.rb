# == Schema Information
# Schema version: 9
#
# Table name: entity_contacts
#
#  id            :integer       not null, primary key
#  entity_id     :integer       not null
#  nature_id     :integer       not null
#  norm_id       :integer       not null
#  active        :boolean       default(TRUE), not null
#  closed_on     :date          
#  line_2        :string(38)    
#  line_3        :string(38)    
#  line_4_number :string(38)    
#  line_4_street :string(38)    
#  line_5        :string(38)    
#  line_6_code   :string(38)    
#  line_6_city   :string(38)    
#  phone         :string(32)    
#  fax           :string(32)    
#  mobile        :string(32)    
#  email         :string(255)   
#  company_id    :integer       not null
#  created_at    :datetime      
#  created_by    :integer       
#  updated_at    :datetime      
#  updated_by    :integer       
#  lock_version  :integer       default(0), not null
#

class EntityContact < ActiveRecord::Base
  def formatted_address
    norm = self.norm
    ltr = !norm.rtl
    address = ""
    for item in norm.items
      if ltr
        case item.left_nature
          when "eol": address +="<br />"
          when "space": address += " "
          when "text": address += item.left_value
        end
      else
        case item.right_nature
          when "eol": address +="<br />"
          when "space": address += " "
          when "text": address += item.right_value
        end
      end
      
      case item.nature
        when "surname" : address += self.entity.surname
        when "first_name" : address += self.entity.first_name
        when "title" : address += self.entity.nature.title
        when "line_2" : address += self.line_2
        when "line_3" : address += self.line_3
        when "line_4_number" : address += self.line_4_number
        when "line_4_street" : address += self.line_4_street
        when "line_5" : address += self.line_5
        when "line_6_code" : address += self.line_6_code
        when "line_6_city" : address += self.line_6_city
        when "text" : address += self.content
      end
      
      if not ltr
        case item.left_nature
          when "eol": address +="<br />"
          when "space": address += " "
          when "text": address += item.left_value
        end
      else
        case item.right_nature
          when "eol": address +="<br />"
          when "space": address += " "
          when "text": address += item.right_value
        end
      end
    end
    address
  end

end
