require 'csv'

module UploadParsers
  def self.find_value(row, fields)
    return lambda { |column | row[fields[column]] }
  end

  def self.parse_csv(csv_data)
    fields = {}
    records = []

    i = 0
    CSV.parse(csv_data) do |row|
      if i == 0
        row.each_index { |i| fields[row[i]] = i }
      else
        finder = find_value(row, fields)
        uploaded_record = UploadedBeerRecord.new
        uploaded_record.brewery = finder.call('Brewer')
        uploaded_record.variety = finder.call('Brew')
        uploaded_record.cellared_at = finder.call('Cellared Date')

        # Should parse out the year if it's at the end of variety
        if uploaded_record.variety.match(/\d{4}$/)
          result = uploaded_record.variety.match(/\d{4}$/)

          # Remove the year bits
          uploaded_record.variety = uploaded_record.variety.gsub(/(\s*\-\s*)?\d{4}/, '')
          uploaded_record.year = result[0]
        elsif uploaded_record.variety.match(/^\d{4}\s+/)
          result = uploaded_record.variety.match(/^\d{4}/)

          # Remove the year bits
          uploaded_record.variety = uploaded_record.variety.gsub(/^\d{4}\s+/, '')
          uploaded_record.year = result[0]
        end

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

