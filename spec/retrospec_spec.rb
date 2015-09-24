require 'spec_helper'
require 'retrospec'

describe "Retrospec" do
    it {expect(Retrospec::Module.new('/Users/cosman/github/puppetlabs-apache')).to be_a Retrospec::Module }
end
