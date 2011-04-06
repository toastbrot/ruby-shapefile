require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

TEST_DATA_PATH = 'test-data/110m-admin-0-countries/'
TEST_DATA_PREFIX = "110m_admin_0_countries"

describe "ShapefileReader", "#header" do
  before(:all) do
    @shp_file = Shapefile::Reader.new( File.join(TEST_DATA_PATH, TEST_DATA_PREFIX) )
  end

  it "has a filecode of 9994" do
    @shp_file.header.file_code.should == 9994
  end

  it "has a file length of 89938" do
    @shp_file.header.file_length.should == 89938
  end

  it "has shp file version 1000" do
    @shp_file.header.version.should == 1000
  end

  it "has shape type :polygon" do
    @shp_file.header.shape_type.should == :polygon
  end
end