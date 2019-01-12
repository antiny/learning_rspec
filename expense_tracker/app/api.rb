require 'sinatra/base'
require 'json'
require 'pp'
require 'ox'
require 'byebug'
require_relative 'ledger'

module ExpenseTracker
  class API < ::Sinatra::Base
    def initialize(ledger: ExpenseTracker::Ledger.new)
      @ledger = ledger
      super()
    end

    get '/' do 
      'Hello World'
    end

    post '/expenses' do
      expense = deserialize(request.body.read)
      result = @ledger.record(expense)
      if result.success?
        serialize({'expense_id' => result.expense_id}, mime)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end

    get '/expenses/:date' do 
      serialize(@ledger.expenses_on(params['date']), mime)
    end

    private 

    def mime
      if request.accept?('application/json')
        'application/json'
      elsif request.accept?('application/xml')
        'application/xml'
      else
        raise "Unsupported MIME type"
      end
    end

    def serialize(data, mime)
      case mime
      when 'application/xml'
        headers['Content-Type'] = mime
        Ox.dump(data)
      when 'application/json'
        headers['Content-Type'] = mime
        JSON.generate(data)
      else
        raise "Unsupported Mime Type of #{mime}"
      end
    end

    def deserialize(body)
      case mime
      when 'application/xml'
        Ox.parse_obj(body)
      when 'application/json'
        JSON.parse(body, symbolize_names: true)
      else
        raise "Unsupported Mime Type of #{mime}"
      end
    end
  end
end
