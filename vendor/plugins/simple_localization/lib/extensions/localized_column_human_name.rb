# This file contains code which extends ActiveRecords Column class. The aim is
# to localize the Column#human_name method which is heavily used by scaffold.
# 
# So, wheres the prblem? By default the +human_name+ method calls the
# ActiveRecord::Base#human_attribute_name method. The localized_models and
# localized_models_by_lang_file features are overwriting this method to provide
# localized data. However for these overwritten methods to work they need to be
# called on the model class itself (eg. Comment) and not on the Base class.
# 
# Why? Because the localized_models feature only overwrites the
# +human_attribute_name+ method in the model class not in the Base class
# itself. The localized_models_by_lang_file feature overwrites the
# +human_attribute_name+ in the Base class but still needs the name of the
# model class to find the proper section of the language file. When called on
# the Base class the overwritten method has no idea to which model class it
# belongs.
# 
# To solve this we extend the Column class to hold a reference to the model
# class it belongs to. Next on we overwrite the +human_name+ method to call the
# +human_attribute_name+ method on the model class if one is available. The
# last step is to update the Base#columns method which builds the column array
# belonging to a model class. After these columns are defined we just have to
# set thier newly added +model_class+ property to the current class.
# 
# This way the two features work like usual and we should get the localized
# data. Even when using scaffold.

module ActiveRecord #:nodoc:
  
  module ConnectionAdapters #:nodoc:
    class Column
      
      attr_accessor :model_class
      
      alias_method :human_name_without_localization, :human_name
      
      # Overwrites the +human_name+ method to call +human_attribute_name+ on
      # the model_class if possible. Falls back to default behaviour if no
      # model class is set (original method renamed to +human_name_without_localization+).
      def human_name
        self.model_class ? self.model_class.human_attribute_name(@name) : human_name_without_localization
      end

      # Overwrites the +string_to_date+ method to use the localization file
      # to use a parse model for the dates
      def self.string_to_date(string)
        return string unless string.is_a?(String)
        date_array = Date._strptime(string, ArkanisDevelopment::SimpleLocalization::Language[:dates, :date_formats, :db])
        # treat 0000-00-00 as nil
#        Date.civil(2006,12,24)
        Date.civil(date_array[:year], date_array[:mon], date_array[:mday]) rescue nil
      end

      def self.string_to_time(string)
        return string unless string.is_a?(String)
        time_hash = Date._strptime(string, ArkanisDevelopment::SimpleLocalization::Language[:dates, :time_formats, :db])
        #time_hash = Date._parse(string)
        index = string.index(/\.\d\d\d\d\d\d/)
        time_hash[:sec_fraction] = string[index+1, index+6] if index;
        #time_hash[:sec_fraction] = microseconds(time_hash)
        time_array = time_hash.values_at(:year, :mon, :mday, :hour, :min, :sec, :sec_fraction)
        # treat 0000-00-00 00:00:00 as nil
        Time.send(Base.default_timezone, *time_array) rescue DateTime.new(*time_array[0..5]) rescue nil
      end

      def self.string_to_dummy_time(string)
        return string unless string.is_a?(String)
        return nil if string.empty?
        time_hash = Date._strptime(string, ArkanisDevelopment::SimpleLocalization::Language[:dates, :time_formats, :db])
#        time_hash = Date._parse(string)
        index = string.index(/\.\d\d\d\d\d\d/)
        time_hash[:sec_fraction] = string[index+1, index+6] if index;
#        time_hash[:sec_fraction] = microseconds(time_hash)
        # pad the resulting array with dummy date information
        time_array = [2000, 1, 1]
        time_array += time_hash.values_at(:hour, :min, :sec, :sec_fraction)
        Time.send(Base.default_timezone, *time_array) rescue nil
      end


     
    end


    module Quoting
      # Quotes the column value to help prevent
      # {SQL injection attacks}[http://en.wikipedia.org/wiki/SQL_injection].
      def quote(value, column = nil)
        # records are quoted as their primary key
        return value.quoted_id if value.respond_to?(:quoted_id)

        case value
          when String, ActiveSupport::Multibyte::Chars
            value = value.to_s
            if column && column.type == :binary && column.class.respond_to?(:string_to_binary)
              "'#{quote_string(column.class.string_to_binary(value))}'" # ' (for ruby-mode)
            elsif column && [:integer, :float].include?(column.type)
              value = column.type == :integer ? value.to_i : value.to_f
              value.to_s
            else
              "'#{quote_string(value)}'" # ' (for ruby-mode)
            end
          when NilClass                 then "NULL"
          when TrueClass                then (column && column.type == :integer ? '1' : quoted_true)
          when FalseClass               then (column && column.type == :integer ? '0' : quoted_false)
          when Float, Fixnum, Bignum    then value.to_s
          # BigDecimals need to be output in a non-normalized form and quoted.
          when BigDecimal               then value.to_s('F')
          # Date need to be formatted to the database format
          when Date                     then "'#{value.to_s :db}'" 
          when Time, DateTime           then "'#{quoted_date(value)}'"
          else                          "'#{quote_string(value.to_yaml)}'"
        end
      end
    end


  end
  
  class Base
    
    class << self
      
      alias_method :columns_without_localization, :columns
      
      # Updates the ActiveRecord::Base#columns method (orginal renamed to
      # +columns_without_localization+) to set the +model_class+ property on
      # every column belonging to this model class. This is necessary for the
      # overwritten Column#human_name method to work.
      def columns
        unless @columns
          columns_without_localization
          @columns.each do |column|
            column.model_class = self
          end
        else
          columns_without_localization
        end
      end
      
    end
    
  end
 
end





module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      module Conversions

        def to_time(form = :utc)
          *date_array = Date._strptime(self, ArkanisDevelopment::SimpleLocalization::Language[:dates, :time_formats, :default])
          index = self.index(/\.\d\d\d\d\d\d/)
          *date_array[:sec_fraction] = string[index+1, index+6] if index;
#          ::Time.send(form, *ParseDate.parsedate(self))
          ::Time.send(form, *date_array)
        end

        def to_date
#          ::Date.new(*ParseDate.parsedate(self)[0..2])
          date_array = Date._strptime(self, ArkanisDevelopment::SimpleLocalization::Language[:dates, :date_formats, :default])
          # treat 0000-00-00 as nil
#          Date.civil(2004,8,16)
          Date.civil(date_array[:year], date_array[:mon], date_array[:mday]) rescue nil
        end
      end
    end
  end
end



