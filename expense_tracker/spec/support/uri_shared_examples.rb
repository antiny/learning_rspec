RSpec.shared_examples 'URI like' do | klass | 
  it 'parses the scheme' do 
    expect(klass.parse('https://a.com').scheme).to eq('https')
  end

  it 'parses the host' do 
    expect(klass.parse('http://foo.com').host).to eq('foo.com')
  end

  it 'parses the port' do 
    expect(klass.parse('http://foo.com:9876').port).to eq(9876)
  end

  it 'parses the path' do 
    expect(klass.parse('https://foo.com:9876/foo').path).to eq('/foo')
  end
end
