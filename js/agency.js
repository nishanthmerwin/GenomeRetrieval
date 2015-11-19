/*!
 * Start Bootstrap - Agency Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function() {
    $('a.page-scroll').bind('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 1500, 'easeInOutExpo');
        event.preventDefault();
    });
});

// Highlight the top nav as scrolling occurs
$('body').scrollspy({
    target: '.navbar-fixed-top'
})

// Closes the Responsive Menu on Menu Item Click
$('.navbar-collapse ul li a').click(function() {
    $('.navbar-toggle:visible').click();
});


// function for radio buttons in selecting genome
$(function() {
	
	// iterates over each element in clickContainer
    $('.clickContainer input[type="radio"]').each(function(index) {
		
		// checks the current value of i each element
        console.log($(this));
        
		// sets the value of id to be radio + index(what is currently there)
		$(this).attr('id', 'radio' + index);
		
		// returns the parent HTML value of clickContainer
		// assigns that to an html element called <labelA>
		// saves it all into a variable
        var label = $('<labelA />', {'for': 'radio' + index}).html($(this).parent().html());
        
		// assigns the $label html tag to the parent of the clickContainer
		$(this).parent().empty().append(label);
    });
	
	
	// calls the function defined above when THIS is clicked
    $('labelA').click(function () {
		
		
		// When label is clicked, it removes the class selected of the one with the "label" element
	   $('labelA').removeClass('selected');
	   $("input[name='question']").prop('checked',false);
	   
	   
	   // when label is clicked, it adds the class selected
       $(this).addClass('selected');
	   $(this).children().prop('checked',true);
    });  
		
});



// Function that selects all when clicked

$('#ALL').click(function() {
   // alert($(this).prop('checked'));
    if ($(this).is(':checked') == true) {
        $("input[name='rGroup']").prop('checked', true);
    }else{
        $("input[name='rGroup']").prop('checked', false);
    }
});



// Function for reset button
$('.ResetBTN').click(function(){
	$("input[name='rGroup']").prop('checked', false);
	$('labelA').removeClass('selected');
	$('labelA').prop('checked', false);
});
