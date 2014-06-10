class CallsController < ApplicationController

	def dial_in
		render :xml => "<Response>
    <Say>Hello Monkey</Say>
</Response>"
	end
end
