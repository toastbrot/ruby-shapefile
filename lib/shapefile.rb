require 'rubygems'
require 'dbf'
require 'logger'
require 'converters'

module Shapefile

# shp specification at http://www.esri.com/library/whitepapers/pdfs/shapefile.pdf
class Reader
  def has_attributes?
    not @dbf_filename.nil?
  end

  def header
    @header||=read_header
  end

  def shapes
    @shapes||=read_shapes
  end
  
  def initialize(basename)
    @log = Logger.new(STDOUT)
    @log.level = Logger::WARN

    raise "no base file name specified" if basename.nil? or basename.empty?

    if File.extname(basename)=="shp"
      @shp_filename = basename
    else
      @shp_filename = "#{basename}.shp"
      @dbf_filename = File.exists?("#{basename}.dbf") ? "#{basename}.dbf" : nil

      @log.warn("couldn't find #{basename}.dbf - won't read any attributes") if not has_attributes?
    end

    raise "shp file #{@shp_filename} does not exist" if not File.exists?(@shp_filename)
  end

  private
  
  def read_header
    f = File.open(@shp_filename, "rb")
    bytes = f.read(100)
    f.close
    header = Header.new *(bytes.unpack("N@24NLL").push(BoundingBox3d.new *(bytes.unpack("@36EEEEEEEE"))))
    header.shape_type = Shapefile::shape_type_for_id(header.shape_type)
    header
  end
  
  def read_shapes
    shapes = []
    
    File.open(@shp_filename, "rb") do |f|
      f.seek(100) #seek past header

      bytes_remaining = (header.file_length*2)-100
      while bytes_remaining>0
        shape, bytes_read = read_record(f)        
        shapes.push shape
        bytes_remaining -= bytes_read
      end
    end
    
    if has_attributes?
      attr_table = DBF::Table.new(@dbf_filename)
      
      shapes.each_with_index do |shape, i|
        attrs = {}
        record = attr_table.record(i)
        record.attributes.each do |key, value|
          attrs[key] = value
        end
        shape.attributes = attrs
      end      
    end
    shapes
  end
  
  def read_record(file)
    rec_num, content_length = file.read(8).unpack("NN")
    content = file.read(content_length*2)

    shape_type = Shapefile::shape_type_for_id(content.unpack("L").first)
  
    ret = nil
    unless shape_type.nil?
      ret = Shapefile::convert(shape_type, content)
    end
    
    [ret, (content_length*2)+8]
  end

end

private

SHAPE_TYPE_MAP = { 
  0 => :null_shape,
  1 => :point,
  3 => :poly_line,
  5 => :polygon,
  8 => :multi_point,
  11 => :point_z,
  13 => :poly_line_z,
  15 => :polygon_z,
  18 => :multi_point_z,
  21 => :point_m,
  23 => :poly_line_m,
  25 => :polygon_m, 
  28 => :multi_point_m,
  31 => :multi_patch
}

def self.shape_type_for_id(shape_type_id)  
  SHAPE_TYPE_MAP[shape_type_id]
end

Header = Struct.new(:file_code, :file_length, :version, :shape_type, :bounding_box)
BoundingBox2d = Struct.new(:x_min, :y_min, :x_max, :y_max)
BoundingBox3d = Struct.new(:x_min, :y_min, :x_max, :y_max, :z_min, :z_max, :m_min, :m_max)

class NullShape < Struct.new(:attributes)
  @@TYPE = :null_shape
end

class Point < Struct.new(:attributes, :x, :y)
  @@TYPE = :point
end

class MultiPoint < Struct.new(:attributes, :bounding_box, :points)
  @@TYPE = :multi_point
end

class PolyLine < Struct.new(:attributes, :bounding_box, :parts, :points)
  @@TYPE = :poly_line  
end

class Polygon < Struct.new(:attributes, :bounding_box, :parts, :points)
  @@TYPE = :polygon  
end

end