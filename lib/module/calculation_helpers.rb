module CalculationHelpers

class << self

  	# This method is the logic to perform the fizzbuzz operation. Throws ArgumentError if input is
	# missing or not numeric
	def fizzbuzz(number)
		raise ArgumentError, "FizzBuzz input not a digit" if !CalculationHelpers.numeric?(number) || number.nil?
		raise "Only numbers between 0 and 200" if !number.between?(0,200)
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

	def numeric?(number)
    	return true if number =~ /^\d+$/
    	true if Float(number) rescue false
  	end

end

end