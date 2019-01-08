RSpec.describe 'An ideal sandwich' do 

  Sandwich = Struct.new(:taste, :toppings)

  let(:sandwich) { Sandwich.new('delicious', [])}

  it 'is delicious' do
    taste = sandwich.taste

    expect(taste).to eq('delicious')
  end

  it 'lets me add toppings' do 
    sandwich.toppings << 'cheese'

    toppings = sandwich.toppings

    expect(toppings).not_to be_empty
    expect(toppings).to include('cheese')
  end
end
