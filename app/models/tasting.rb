class Tasting
  include MongoMapper::EmbeddedDocument

  belongs_to :beer
  key :notes
  key :tasted_at

end
