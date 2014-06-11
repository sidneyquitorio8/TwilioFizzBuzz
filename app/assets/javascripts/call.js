$(document).ready(function() {

	$('#inputPhoneNumber').on('input', function() {
	    validatePhoneNumber($('#inputPhoneNumber').val())
	});

	function validatePhoneNumber(number) {
		if(number.length == 10 && $.isNumeric(number)) {
			$('#phoneNumberContainer').attr('class', 'col-sm-5 has-success');
			$('#phoneNumberSubmit').attr('class', 'btn btn-primary');
		}
		else {
			$('#phoneNumberContainer').attr('class', 'col-sm-5 has-error');
			$('#phoneNumberSubmit').attr('class', 'btn btn-primary disabled');
		}
	}

	$('#phoneNumberSubmit').click(function(event) {
	    $.ajax({
		    type: "POST",
		    dataType: 'json',
		    url: "/calls/dial_out",
		    data: {
		        number: $('#inputPhoneNumber').val()
		    },
		    success: function(response) {
		    	if(response['result'] == true) {
		    		alert("Hope you enjoyed your call");
		    	}
		    	else {
		    		alert("Try again");
		    	}
		    }
	    });
	});

});