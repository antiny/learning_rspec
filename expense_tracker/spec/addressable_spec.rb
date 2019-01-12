require 'addressable'
require_relative 'support/uri_shared_examples'

RSpec.describe Addressable do 
  it_behaves_like 'URI like', Addressable::URI

  it 'defaults port to nil when not specified' do 
    expect(Addressable::URI.parse('http://foo.com').port).to be_nil
  end
end