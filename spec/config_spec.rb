require 'spec_helper'
require 'retrospec/config'


describe 'config' do
  let(:config_obj) do
       Retrospec::Config.new
  end

  it do
     expect(config_obj.config_data['plugins::puppet::templates::ref']).to eq('master')
     expect(config_obj.config_data).to be_a Hash
  end

  it 'returns the correct context' do
    context = Retrospec::Config.plugin_context(config_obj.config_data, 'puppet')
    expect(context.keys.count).to be >= 2
    expect(context['plugins::puppet::templates::ref']).to eq('master')
    expect(context).to be_a Hash
  end
end