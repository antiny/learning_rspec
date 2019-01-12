# frozen_string_literal: true

require_relative '../../../app/ledger'
require_relative '../../../config/sequel'
require 'pp'

module ExpenseTracker
  RSpec.describe Ledger, :aggregate_failures, :db do
    let(:ledger) { Ledger.new }
    let(:expense) do
      {
        'payee': 'Starbuck',
        'amount': 5.75,
        'date': '2017-06-10'
      }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'successfully saves the expense to the db' do
          result = ledger.record(expense)

          expect(result).to be_success
          expect(DB[:expenses].all).to match(a_hash_including(
                                               id: result.expense_id,
                                               payee: 'Starbuck',
                                               amount: 5.75,
                                               date: Date.iso8601('2017-06-10')
                                             ))
        end
      end

      context 'when the expense lacks a payee' do
        it 'rejects the expense as invalid' do
          expense.delete(:payee)

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to be_nil
          expect(result.error_message).to include('`payee` is required')
        end

        it 'does not create new record' do
          expense.delete(:payee)

          expect { ledger.record(expense) }.not_to change { DB[:expenses].count }
        end
      end

      context 'when the expense lacks a date' do
        it 'rejects the expense as invalid' do
          expense.delete(:date)

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to be_nil
          expect(result.error_message).to include('`date` is required')
        end

        it 'does not create new record' do
          expense.delete(:date)

          expect { ledger.record(expense) }.not_to change { DB[:expenses].count }
        end
      end

      context 'when the expense lacks an amount' do
        it 'rejects the expense as invalid' do
          expense.delete(:amount)

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to be_nil
          expect(result.error_message).to include('`amount` is required')
        end

        it 'does not create new record' do
          expense.delete(:amount)

          expect { ledger.record(expense) }.not_to change { DB[:expenses].count }
        end
      end
    end

    describe '#expenses_on' do
      it 'returns all expenses for the provided date' do
        result_1 = ledger.record(expense.merge(date: '2017-06-10'))
        result_2 = ledger.record(expense.merge(date: '2017-06-10'))
        result_3 = ledger.record(expense.merge(date: '2017-06-11'))

        result = ledger.expenses_on('2017-06-10')
        expect(result).to contain_exactly(
          a_hash_including(id: result_1.expense_id),
          a_hash_including(id: result_2.expense_id)
        )
      end

      it 'returns a blank array when there are no matching expenses' do
        expect(ledger.expenses_on('2017-06-10')).to eq([])
      end
    end
  end
end
