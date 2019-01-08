require 'sinatra/base'
require 'json'

module ExpenseTracker
  class API < ::Sinatra::Base
    get '/' do 
      'Hello World'
    end
    
    post '/expenses' do
      JSON.generate(expense_id: 1)
    end

    get '/expenses/:date' do 
      JSON.generate([])
    end
  end
end
