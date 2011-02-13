class ProcessConfirmedImport
  @queue = :uploads

  def self.perform(job_id, user_id)
    # Get all the uploaded beer records with this thinger.
    records = UploadedBeerRecord.where(:job_id => job_id).all
    cellar = Cellar.find_by_user_id(user_id)
    
    uri = URI.parse(ENV["REDIS_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    
    begin
      redis["cellar_import:#{user_id}:status"] = 4

      records.each do |record|
          brewery = Brewery.find_or_create_by_name(record.brewery)
          brew_type = BrewType.find_or_create_by_name(record.brew_style)
          brew = brewery.brews.find_by_name(record.variety) || brewery.brews.create(:name => record.variety, :brew_type => brew_type)

          bottle_size = BottleSize.find_or_create_by_name(record.bottle_size)
          bottle_size.save! unless bottle_size.persisted?

          quantity = (record.quantity and record.quantity.to_i > 0) ? record.quantity.to_i : 1
          year = (record.year and record.year.match(/^\d{4}$/)) ? record.year.to_i : 2010
          cellared_at = (record.cellared_at.nil? or record.cellared_at.empty?) ? DateTime.now.to_s : DateTime.parse(record.cellared_at).to_s

          # Save the brew!
          cellar.beers.create! :brew => brew, :bottle_size => bottle_size, :year => year, :quantity => quantity, :cellared_at => cellared_at
      end

      # Also delete all the records
      records.each do |record|
        record.delete
      end

      redis["cellar_import:#{user_id}:status"] = 2
    rescue Exception => ex
      p ex
      redis["cellar_import:#{user_id}:status"] = 3 # Failed to import.
    ensure
      redis.del("cellar_import:#{user_id}:job_id")
    end
  end
end
