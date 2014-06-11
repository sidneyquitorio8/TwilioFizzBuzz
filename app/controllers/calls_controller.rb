class CallsController < ApplicationController
	before_filter :authenticate_request, :only => :dial_in

 	require 'calculation_helpers'

 	# Displays the homepage
	def index
		@calls = Call.all
	end

	# This action handles the calling of the user, then redirects the user to the original dial_in prompt
	def dial_out
		begin #error handling for params :delay & :number
			if params[:delay]
				# Throws an error if delay is not numeric
				raise "Delay is not a valid number" if !CalculationHelpers.numeric?(params[:delay])
				Call.delay(run_at: params[:delay].to_i.minutes.from_now).outgoing_call(params[:number])
			else
				Call.outgoing_call(params[:number]) #throws an error if :number is not 7 digits & not numeric
			end
			Call.create(number: params[:number], delay: params[:delay])
			@result = {}
			@result['status'] = true
			render json: @result
		rescue Exception => e
			puts e.message
			response = Twilio::TwiML::Response.new do |r|
			  r.Say 'Not a valid number'
			end
			@result = {}
			@result['status'] = false
			@result['error'] = e.message
			render json: @result
		end
	end

	# This action handles the incoming calls made to the twilio number
	def dial_in
		response = Twilio::TwiML::Response.new do |r|
		  r.Say 'Welcome to FizzBuzz'
		  r.Gather :timeout => '10', :finishOnKey => '#', :action => '/calls/dial_in_response', :method => 'POST' do |g|
		    g.Say 'Enter a number, then press pound to continue'
		  end
		end

		render :xml => response.text
	end

	# This action handles the user's response to the void prompt. Input is sanitized by only handling the 
	# proper parameters and verifying that they are numbers
	def dial_in_response
		digit = params[:Digits]
		# error handling to make sure digit is not nil & it exists
		begin
			fizzbuzz_string = CalculationHelpers.fizzbuzz(digit)
			response = Twilio::TwiML::Response.new do |r|
			  r.Say fizzbuzz_string
			end
			render :xml => response.text
		rescue ArgumentError => e
			response = Twilio::TwiML::Response.new do |r|
			  r.Say 'Not a valid input'
			end
			render :xml => response.text
		rescue Exception => e
			response = Twilio::TwiML::Response.new do |r|
			  r.Say 'Number should be between 0 and 200'
			end
			render :xml => response.text
		end 
	end

	# This method handles a call replay
	def replay_call
		begin
			raise "Incorrect parameter format" if params[:call_id].nil? || !CalculationHelpers.numeric?(params[:call_id])
			call = Call.find(params[:call_id])
			if call.delay.present?
				params[:delay] = call.delay
			end
			params[:number] = call.number
			dial_out
		rescue ActiveRecord::RecordNotFound
			@result = {}
			@result['status'] = false
			@result['error'] = "Call does not exist"
			render json: @result			
		rescue Exception => e
			@result = {}
			@result['status'] = false
			@result['error'] = e.message
			render json: @result
		end
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
end