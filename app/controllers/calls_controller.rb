class CallsController < ApplicationController
	# before_filter :authenticate_request

	# make sure to sanitize input
	# make sure to handle cases where params are not from twilio
	def dial_in
		response = Twilio::TwiML::Response.new do |r|
		  r.Say 'Welcome to FizzBuzz'
		  r.Gather :timeout => '10', :finishOnKey => '#', :action => '/dial_in_response', :method => 'POST' do |g|
		    g.Say 'Enter a digit, then press pound'
		  end
		end

		render :xml => response.text
		# render :xml => "<Response><Say>Hello Monkey</Say><Gather numDigits='1' action='/test' method='POST'>
  #       <Say>To speak to a real monkey, press 1.  Press any other key to start over.</Say>
  #   </Gather></Response>"
	end

	# make sure to sanitize input
	# make sure to handle cases where params are not from twilio
	def dial_in_response
		digit = params[:Digits]
		response = Twilio::TwiML::Response.new do |r|
		  r.Say 'You have entered' + digit
		end
		# string = "<Response><Say>"+ digit  +"</Say></Response>"
		render :xml => response.text
	end

	private 

	def authenticate_request
		twilio_sig = request.headers['HTTP_X_TWILIO_SIGNATURE']
		twilio_validator = Twilio::Util::RequestValidator.new(ENV['TWILIO_AUTH'])

		verified = twilio_validator.validate(request.url, params, twilio_sig)

		unless verified
			response = Twilio::TwiML::Response.new do |r|
			  r.Hangup
			end
			render :xml => response.text
		end
	end
end
