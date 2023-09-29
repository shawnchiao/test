require 'spec_helper'
describe 'lmsweb' do

  context 'with defaults for all parameters' do
    it { should contain_class('lmsweb') }
  end
end
