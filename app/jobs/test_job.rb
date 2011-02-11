module TestJob
  @queue = :test

  def perform
    puts "Hello, world!"
  end
end
