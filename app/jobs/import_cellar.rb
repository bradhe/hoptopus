class ImportCellar
  @queue = :uploads
  
  include UploadParsers
   
  def perform(file_path)
    records = parse_csv(file_path)
    
    job_id = UUID.timestamp_create().to_s
    
    records.each do |r|
      r.job_id = job_id
      
      # Also clean up the brewery if it exists.
      b = Brewery.find(:all, :conditions => ['sanitized_name LIKE ?', "#{r.brewery.downcase.gsub(/[^\w]/,'')}%"]).first          
      unless b.nil?
        r.brewery = b.name
      end
    
      # Save this job
      r.save
    end
  end
end