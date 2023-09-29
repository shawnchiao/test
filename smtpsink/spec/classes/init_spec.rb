require 'spec_helper'
describe 'smtpsink' do

  context 'with defaults for all parameters' do
    it { should contain_class('smtpsink') }
  end
end
