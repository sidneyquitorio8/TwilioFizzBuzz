class Call < ActiveRecord::Base
  attr_accessible :delay, :number

  include CalculationHelpers #mixin allows us to use the model that contains fizzbuzz & other service methods

  	def self.outgoing_call(number)
  		raise ArgumentError, "Not a valid number" if !CalculationHelpers.numeric?(number) || number.nil? || number.length != 10
		client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
		call = client.account.calls.create(
		  :from => '7027896467',   # From your Twilio number
		  :to => number,     # To any number
		  # Fetch instructions from this URL when the call connects
		  :url => 'http://twilio-fizz-buzz.herokuapp.com/calls/dial_in'
		)
  	end
end
