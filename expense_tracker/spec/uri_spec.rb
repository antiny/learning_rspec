require 'uri'
require_relative 'support/uri_shared_examples'

RSpec.describe URI do 
  it_behaves_like 'URI like', URI

  it 'defaults to port for an http URI to 80' do 
    expect(URI.parse('http://foo.com').port).to eq(80)
  end

  it 'defaults to port for an https URI to 443' do 
    expect(URI.parse('https://foo.com').port).to eq(443)
  end
end