require 'spec_helper'
describe 'lmsutils' do
  context 'with default values for all parameters' do
    it { should contain_class('lmsutils') }
  end
end
