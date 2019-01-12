# frozen_string_literal: true

require 'rack/test'
require 'json'
require 'pp'
require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API', :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))

      expense.merge(id: parsed['expense_id'])
    end

    it 'records submitted expense' do
      coffee = {
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2017-06-10'
      }

      zoo = {
        'payee' => 'Zoo',
        'amount' => 15.25,
        'date' => '2017-06-10'
      }

      groceries = {
        'payee' => 'Whole Foods',
        'amount' => 95.20,
        'date' => '2017-06-11'
      }

      post_expense(coffee)
      post_expense(zoo)
      post_expense(groceries)

      get '/expenses/2017-06-10'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses).to contain_exactly(
        a_hash_including(coffee),
        a_hash_including(zoo)
      )
    end
  end
end
