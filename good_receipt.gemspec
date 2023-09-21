lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative './lib/good_receipt/version'

Gem::Specification.new do |spec|
  spec.name          = 'good_receipt'
  spec.version       = GoodReceipt::VERSION
  spec.authors       = ['Sean Robenalt']
  spec.email         = ['srob0722@gmail.com']
  spec.summary       = 'Lightweight Ruby gem for generating and managing good receipt PDFs for your business.'
  spec.description   = 'This gem provides functionality for creating and managing receipts in Ruby applications. It uses the Prawn gem for generation, and then uses the Google Cloud Storage gem to send the generated receipts to the cloud.'
  spec.homepage      = 'https://github.com/seanrobenalt/good-receipt'
  spec.license       = 'MIT'

  spec.files         = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'google-cloud-storage', '1.21.1'
  spec.add_dependency 'prawn', '2.2.2'
  spec.add_dependency 'prawn-table', '0.2.2'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.required_ruby_version = '>= 2.7.6'
end
