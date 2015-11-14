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
    $('.clickContainer input[type="radio"]').each(function(index) {
        console.log($(this));
        $(this).attr('id', 'radio' + index);
        var label = $('<label />', {'for': 'radio' + index}).html($(this).parent().html());
        $(this).parent().empty().append(label);
    });
    $('label').click(function () {
       $('label').removeClass('selected');
       $(this).addClass('selected');
    });        
});