#$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rspec'
require 'lumberg'
require 'lumberg/exceptions'
require 'webmock/rspec'
require 'vcr'
require 'timeout'

# Load supporting files in spec/support
Dir["#{Lumberg::base_path}/../spec/support/**/*.rb"].each do |f|
  require f
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { record: :none }
end

def live_test?
  !ENV['WHM_REAL'].nil?
end

def requires_attr(attr, &block)
  expect { block.call }.to raise_error(Lumberg::WhmArgumentError, /Missing required parameter: #{attr}/i)
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
  c.before(:each) do
    if live_test?
      @whm_hash = ENV['WHM_HASH'].dup
      @whm_host = ENV['WHM_HOST'].dup
    else
      @whm_hash = 'iscool'
      @whm_host = 'myhost.com'
      Resolv.stub(:getaddress).with(@whm_host).and_return('11.22.33.44')
    end
  end
end
