RSpec.describe 'An ideal sandwich' do 

  Sandwich = Struct.new(:taste, :toppings)

  it 'is delicious' do
    sandwich = Sandwich.new('delicious', [])

    taste = sandwich.taste

    expect(taste).to eq('delicious')
  end

  it 'lets me add toppings' do 
    sandwich = Sandwich.new('delicious', [])
    sandwich.toppings << 'cheese'

    toppings = sandwich.toppings

    expect(toppings).to include('cheese')
  end
end