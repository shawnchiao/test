require 'spec_helper'
describe 'lmsrp' do

  context 'with defaults for all parameters' do
    it { should contain_class('lmsrp') }
  end
end
