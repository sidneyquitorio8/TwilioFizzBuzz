class CallsController < ApplicationController

	def dial_in
		render :xml => "<Response><Say>Hello Monkey</Say></Response>"
	end

	def test
		digit = params[:Digits]
		string = "<Response><Say>"+ digit  +"</Say></Response>"
		render :xml => string
	end
end
