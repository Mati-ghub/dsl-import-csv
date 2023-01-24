require 'csv'

class CSVImport
  attr_reader :configuration

  def initialize
    @configuration = CSVImportConfiguration.new
  end

  def self.from_file(filepath)
    import = new
    yield import.configuration
    rows = CSV.read(filepath, col_sep: ";")
    import.process(rows)
  end

  def process(rows)
    rows.map { |row| process_row(row) }
  end

  private 

  def process_row(row)
    obj = {}
    @configuration.columns.each do |col|
      obj[col.name] = col.type.call(row[col.col_number - 1])
    end
    obj
  end
end

class CSVImportConfiguration
  attr_reader :columns
  Column = Struct.new(:name, :col_number, :type)
  
  def initialize
    @columns = []
  end

  def string(name, column:)
    @columns << Column.new(name, column, -> (x) { x.to_s } )
  end

  def integer(name, column:)
    @columns << Column.new(name, column, -> (x) { x.to_i } )
  end

  def decimal(name, column:)
    @columns << Column.new(name, column, -> (x) { x.to_f } )
  end
end

records = CSVImport.from_file("people.csv") do |config|
  config.string :first_name, column: 1
  config.string :last_name, column: 2
  config.integer :age, column: 4
  config.decimal :salary, column: 5
   
end

puts records