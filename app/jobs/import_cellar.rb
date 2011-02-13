class ImportCellar
  @queue = :uploads
  
  include UploadParsers
  include AWS::S3
   
  def self.perform(file_path, user_id)
    csv = S3Object.value file_path, 'hoptopus'
    records = UploadParsers::parse_csv(csv)
    
    job_id = UUIDTools::UUID.timestamp_create.to_s
    
    records.each do |record|
      record.job_id = job_id
      
      # Also clean up the brewery if it exists.
      sanitized_name = record.brewery.downcase.gsub(/[^\w]/,'')

      existing_brewery = Brewery.find(:all, :conditions => ['sanitized_name LIKE ?', "#{sanitized_name}%"]).first
      unless existing_brewery.nil?
        record.brewery = existing_brewery.name
      end
    
      # Save this job
      record.save
    end

    # We're done with this file.
    S3Object.delete file_path, 'hoptopus'

    uri = URI.parse(ENV["REDIS_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    redis["cellar_import:#{user_id}:status"] = 1
    redis["cellar_import:#{user_id}:job_id"] = job_id
  end
end
