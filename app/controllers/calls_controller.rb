class CallsController < ApplicationController
	before_filter :authenticate_request, :only => :dial_in

	# This action handles the incoming calls made to the twilio number
	def dial_in
		response = Twilio::TwiML::Response.new do |r|
		  r.Say 'Welcome to FizzBuzz'
		  r.Gather :timeout => '10', :finishOnKey => '#', :action => '/dial_in_response', :method => 'POST' do |g|
		    g.Say 'Enter a number, then press pound to continue'
		  end
		end

		render :xml => response.text
	end

	# This action handles the user's response to the void prompt. Input is sanitized by only handling the 
	# proper parameters and verifying that they are numbers
	def dial_in_response
		digit = params[:Digits]
		debugger
		# error handling to make sure digit is not nil & it exists
		begin
			fizzbuzz_string = fizzbuzz(digit)
			response = Twilio::TwiML::Response.new do |r|
			  r.Say fizzbuzz_string
			end
			render :xml => response.text
		rescue ArgumentError => e
			response = Twilio::TwiML::Response.new do |r|
			  r.Say 'Not a valid input'
			end
			render :xml => response.text
		end 
	end

	private 

	# This method is the logic to perform the fizzbuzz operation. Throws ArgumentError if input is
	# missing or not numeric
	def fizzbuzz(number)
		raise ArgumentError, "FizzBuzz input not a digit" if !numeric?(number) || number.nil?
		number = number.to_i
		response = ''
		(1..number).each do |num|
			divisible_by_3 = num % 3 == 0
			divisible_by_5 = num % 5 == 0
			if divisible_by_3 && divisible_by_5
				value = "FizzBuzz"
			elsif divisible_by_3
				value = "Fizz"
			elsif divisible_by_5
				value = "Buzz"
			else
				value = num.to_s
			end
			response += value + " "
		end
		response
	end
	
	# This action validates that the request are coming from twilio. It uses the twilio-ruby gem
	# to validate that the twilio signature, url, and params are correctly from twilio
	def authenticate_request
		twilio_signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
		validator = Twilio::Util::RequestValidator.new(ENV['TWILIO_AUTH'])

		twilio_params = params.reject {|k,v| k.downcase == k} #not sure why I have to do this, but doesn't work without it
		valid = validator.validate(request.url, twilio_params, twilio_signature)
		# verified = validator.validate(request.url, params, twilio_signature)

		unless valid
			response = Twilio::TwiML::Response.new do |r|
			  r.Say 'Unvalidated request'
			  r.Hangup
			end
			render :xml => response.text
		end
	end

  	def numeric?(number)
    	return true if number =~ /^\d+$/
    	true if Float(number) rescue false
  	end
end
