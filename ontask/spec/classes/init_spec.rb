require 'spec_helper'
describe 'ontask' do

  context 'with defaults for all parameters' do
    it { should contain_class('ontask') }
  end
end
