$(document).ready(function() {

	$('.replay_call').click(function(event) {
		event.preventDefault();
		id = $('.replay_call').data('call')
	    $.ajax({
		    type: "POST",
		    dataType: 'json',
		    url: "/calls/replay_call",
		    data: { call_id: id },
		    success: function(response) {
		    	if(response['status'] == true) {
		    		alert("Hope you enjoyed your call");
		    	}
		    	else {
		    		alert("Try again");
		    	}
		    	location.reload();
		    }
	    });
	});

	$('#inputPhoneNumber').on('input', function() {
	    validatePhoneNumber($('#inputPhoneNumber').val())
	});

	function validatePhoneNumber(number) {
		if(number.length == 10 && $.isNumeric(number)) {
			$('#phoneNumberContainer').attr('class', 'col-sm-3 has-success');
			$('#phoneNumberSubmit').attr('class', 'btn btn-primary');
		}
		else {
			$('#phoneNumberContainer').attr('class', 'col-sm-3 has-error');
			$('#phoneNumberSubmit').attr('class', 'btn btn-primary disabled');
		}
	}

	$('#inputDelay').on('input', function() {
	    validateDelay($('#inputDelay').val())
	});

	function validateDelay(number) {
		if($('#inputDelay').val() == '') {
			$('#delayContainer').attr('class', 'col-sm-3')
		}
		else {
			if($.isNumeric(number)) {
				$('#delayContainer').attr('class', 'col-sm-3 has-success');
				$('#phoneNumberSubmit').attr('class', 'btn btn-primary');
			}
			else {
				$('#delayContainer').attr('class', 'col-sm-3 has-error');
				$('#phoneNumberSubmit').attr('class', 'btn btn-primary disabled');
			}
		}
	}

	$('#phoneNumberSubmit').click(function(event) {
		event.preventDefault();
		data = {};
		data["number"] = $('#inputPhoneNumber').val();
		if ($('#inputDelay').val() != '') {
			data["delay"] = $('#inputDelay').val()
		}
	    $.ajax({
		    type: "POST",
		    dataType: 'json',
		    url: "/calls/dial_out",
		    data: data,
		    success: function(response) {
		    	if(response['status'] == true) {
		    		alert("Hope you enjoyed your call");
		    	}
		    	else {
		    		alert("Try again");
		    	}
		    }
	    });
	});

});