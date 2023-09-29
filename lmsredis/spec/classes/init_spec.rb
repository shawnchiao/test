require 'spec_helper'
describe 'redis' do
  context 'with default values for all parameters' do
    it { should contain_class('redis') }
  end
end
