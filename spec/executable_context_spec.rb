require 'rspec'
require_relative '../lib/_executable_context'

describe 'Execution Context' do

  context 'test context' do
    it 'that the value is the correct one' do
      _hash = {a: 1, b: 2}
      context = ExcecutableContext.from _hash

      expect(context.instance_eval(&proc {a + b})).to eq 3
    end

    it 'to raise an exception when the execution context should not work' do
      _hash = {a: 1, b: 'bleh'}
      context = ExcecutableContext.from _hash

      expect {context.instance_eval(&proc {a + b})}.to raise_error TypeError
    end
  end

end
