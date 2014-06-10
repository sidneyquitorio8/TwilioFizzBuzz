class CallsController < ApplicationController

	# CORRECTLY VALIDATE TWILIO SIGNATURE


	# make sure to sanitize input
	# make sure to handle cases where params are not from twilio
	def dial_in
		render :xml => "<Response><Say>Hello Monkey</Say><Gather numDigits='1' action='/test' method='POST'>
        <Say>To speak to a real monkey, press 1.  Press any other key to start over.</Say>
    </Gather></Response>"
	end

	# make sure to sanitize input
	# make sure to handle cases where params are not from twilio
	def test
		digit = params[:Digits]
		string = "<Response><Say>"+ digit  +"</Say></Response>"
		render :xml => string
	end
end
