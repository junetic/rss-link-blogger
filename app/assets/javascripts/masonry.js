// $(function(){
//   $('#container').masonry({
//     // options
//     itemSelector : '.box',
//     columnWidth : 10,
//     isFitWidth: true
//   });
// });

$(document).ready(function() {
	var $container = $('#container');
	$container.imagesLoaded( function(){
  		$container.masonry({
    		itemSelector : '.box',
    		isFitWidth: true,
    		isAnimated: true,
    		columnWidth:1
  		});
	});
});