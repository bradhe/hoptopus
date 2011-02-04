class Array
  def chunk(number_of_chunks)
    if number_of_chunks == 0
      return []
    end
    
    chunks = []
    
    # Find out the best approximation for the size of each chunk
    chunk_size = (self.size.to_f / number_of_chunks).ceil
    
    acc = 0
    number_of_chunks.times do
      chunk = []
      
      chunk_size.times do |i|
        chunk << self[acc]
        
        acc += 1
      end
      
      chunks << chunk
    end
    
    chunks
  end
  
  
  def distribute(number_of_chunks)
    if number_of_chunks < 1
      return []
    end
    
    chunks = []
    number_of_chunks.times { chunks << [] }

    acc = 0
    self.each do |i|
      puts acc
      chunks[acc] << i
      acc = acc+1 % number_of_chunks
    end
    
    chunks
  end
end