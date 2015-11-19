/*!
 * Start Bootstrap - Agency Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

 
 // Function for reset button
$('.ProcessBTN').click(function(){
	
	var genome = $('#question').attr('value');
	
	
	
	genome.ajax({
		method: "GET",
		
		url: "../../cgi-bin/letsgo.pl",
		
		data: { genomesName: genome }
		
	})

	
	
});

