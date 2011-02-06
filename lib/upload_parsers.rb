require 'csv'

class UploadedRecord
  attr_accessor :brewery, :variety, :bottle_size, :quantity, :brew_style
end

module UploadParsers
  def find_value(row, fields)
    return lambda { |column | row[fields[column]] }
  end
  
  def csv(file)
    fields = {}
    records = []
    
    i = 0
    CSV.open(file, 'r') do |row|
      if i == 0
        row.each_index { |i| fields[row[i]] = i }
      else
        finder = find_value(row, fields)
        uploaded_record = UploadedRecord.new
        uploaded_record.brewery = finder.call('Brewer')
        uploaded_record.variety = finder.call('Variety')
        uploaded_record.bottle_size = finder.call('Size')
        uploaded_record.quantity = finder.call('Quantity')
        uploaded_record.brew_style = finder.call('Style')
        
        records << uploaded_record
      end
      
      i += 1
    end
    
    # Whew
    records
  end
end

