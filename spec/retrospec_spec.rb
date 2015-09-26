require 'spec_helper'
require 'retrospec'

describe "Retrospec" do
    it {expect{Retrospec::Module.new('/Users/cosman/github/puppetlabs-apache', Retrospec::Plugins::V1::Plugin)}.to raise_error NotImplementedError }
end
