class ImportCellar
  @queue = :uploads
  
  include UploadParsers
   
  def perform(file_path)
    records = parse_csv(file_path)
    
    job_id = UUIDTools::UUID.timestamp_create.to_s
    
    records.each do |record|
      record.job_id = job_id
      
      # Also clean up the brewery if it exists.
      sanitized_name = r.brewery.downcase.gsub(/[^\w]/,'')

      existing_brewery = Brewery.find(:all, :conditions => ['sanitized_name LIKE ?', "#{sanitized_name}%"]).first
      unless existing_brewery.nil?
        record.brewery = existing_brewery.name
      end
    
      # Save this job
      record.save
    end

    # We're done with this file.
    File.delete path
  end
end
