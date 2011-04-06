$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'shapefile'

# creating a new reader
r = Shapefile::Reader.new("../test-data/110m-admin-0-countries/110m_admin_0_countries")

# dumping the .shp header
puts r.header

# dumping the first shape
puts r.shapes[0]

# printing the name attribute of each shape
r.shapes.each { |a|
  puts a.attributes["name"]
}

