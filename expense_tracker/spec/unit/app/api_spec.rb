# frozen_string_literal: true

require_relative '../../../app/api'
require_relative '../../../app/ledger'
require 'rack/test'
require 'ox'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    TYPE_XML  = 'application/TYPE_XML'
    TYPE_JSON = 'application/json'

    def app
      API.new(ledger: ledger)
    end

    def parsed_response
      JSON.parse(last_response.body)
    end

    def parsed_response_from_TYPE_XML
      Ox.parse_obj(last_response.body)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { some: 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(ResultRecord.new(true, 417, nil))
        end

        it 'returns the expense_id' do
          post '/expenses', JSON.generate(expense)

          expect(parsed_response).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end

        context 'when request with TYPE_XML format' do
          it 'returns the expense_id' do
            header 'Accept', TYPE_XML
            post '/expenses', Ox.dump(expense)

            expect(parsed_response_from_TYPE_XML).to include('expense_id')
          end

          it 'responds with application/TYPE_XML content-type' do
            header 'Accept', TYPE_XML
            post '/expenses', Ox.dump(expense)

            expect(last_response.header['Content-Type']).to eq(TYPE_XML)
          end

          it 'responds with a 200 (OK)' do
            header 'Accept', TYPE_XML
            post '/expenses', Ox.dump(expense)

            expect(last_response.status).to eq(200)
          end
        end
      end

      context 'when the expense fails the validation' do
        let(:expense) { { some: 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(ResultRecord.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          expect(parsed_response).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable Entity)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      let(:ledger) { instance_double('ExpenseTracker::Ledger') }

      context 'when expenses exist on the given date' do
        let(:expenses) { [{ 'expense1' => 'expense1' }, { 'expense 2' => 'expense 2' }] }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(any_args)
            .and_return(expenses)
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2017-10-10'

          expect(parsed_response).to be_kind_of(Array)
          expect(parsed_response[0]).to include('expense1')
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/2017-10-10'

          expect(last_response.status).to eq(200)
        end

        context 'when request for TYPE_XML format' do
          it 'returns the expense records as TYPE_XML' do
            header 'Accept', TYPE_XML
            get '/expenses/2017-10-10'

            expect(parsed_response_from_TYPE_XML).to be_kind_of(Array)
            expect(parsed_response_from_TYPE_XML[0]).to include('expense1')
            expect(parsed_response_from_TYPE_XML[1]).to include('expense 2')
          end

          it 'responds with application/TYPE_XML content-type' do
            header 'Accept', TYPE_XML
            get '/expenses/2017-10-10'

            expect(last_response.header['Content-Type']).to eq(TYPE_XML)
          end
        end
      end

      context 'when there are no expense on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(any_args)
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          get '/expenses/2017-10-10'

          expect(parsed_response).to be_kind_of(Array)
          expect(parsed_response).to be_empty
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/2017-10-10'

          expect(last_response.status).to eq(200)
        end

        context 'when request for TYPE_XML format' do
          it 'returns an empty array as TYPE_XML' do
            header 'Accept', TYPE_XML
            get '/expenses/2017-10-10'

            expect(parsed_response_from_TYPE_XML).to be_kind_of(Array)
            expect(parsed_response_from_TYPE_XML).to be_empty
          end
        end
      end
    end
  end
end