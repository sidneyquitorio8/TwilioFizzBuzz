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
		if digit && numeric?(digit)
		response = Twilio::TwiML::Response.new do |r|
		  r.Say 'You have entered' + digit
		end
		render :xml => response.text
	end

	private 

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
