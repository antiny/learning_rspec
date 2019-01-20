require 'pp'

RSpec.describe Hash, :outer_group do 
  it 'is used by RSpec for metadata', :fast, :focus1, :test_aa do |example|
    pp example.metadata
  end
end
