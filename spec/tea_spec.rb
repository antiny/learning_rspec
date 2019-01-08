RSpec.describe 'A cup of tea' do 
  class Tea 
    def flavor
      :earl_gray
    end

    def temperature 
      205.0
    end
  end

  let(:tea) { Tea.new }

  it 'tastes like Earl Grey' do 
    expect(tea.flavor).to be :earl_gray
  end

  it 'is hot' do 
    expect(tea.temperature).to be > 200.0
  end
end