require 'spec_helper'
describe 'vstsagent' do

  context 'with defaults for all parameters' do
    it { should contain_class('vstsagent') }
  end
end
