require 'logger'

module Shapefile  
  def self.convert(shape_type, record_content)
    @converters ||= create_converters
    
    if @converters.has_key?shape_type
      @converters[shape_type].call record_content
    else
      @@log.warn "no converter for shape #{shape_type} found"
      nil
    end
  end

  private 

  @@log = Logger.new(STDOUT)
  @@log.level = Logger::WARN
  
  def self.create_converters
    {
      :null_shape => lambda { |rc| NullShape.new },
      :point => lambda { |rc| Point.new *(content.unpack("@4EE"))},
      :multi_point => lambda { |rc| 
       bytes = rc.unpack("LEEEEL")
       points = []
       (0...bytes[5]).each {|i| 
        points.push Point.new(*(rc.unpack("@#{40+(i*16)}EE")))
       }
       MultiPoint.new BoundingBox2d.new(*bytes[1..4]), points
      },
      :poly_line => lambda { |rc| Polygon.new *read_poly_shape(rc) },
      :polygon => lambda { |rc| Polygon.new *read_poly_shape(rc) }
    }
  end

  def self.read_poly_shape(rc)
    bytes = rc.unpack("LEEEELL")

    num_parts = bytes[5]
    parts = (0...num_parts).map { |i| rc.unpack("@#{44+(i*4)}L") }
    
    num_points = bytes[6]
    points_offset = 44 + (4 * num_parts)
    points = (0...num_points).map {|i| 
      Point.new(*(rc.unpack("@#{points_offset+(i*16)}EE")))
    }

    [BoundingBox2d.new(*bytes[1..4]), parts, points]
  end
end