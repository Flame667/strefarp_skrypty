$( function() {
    init();
    window.addEventListener( 'message', function( event ) {
		if(event.data.type == 'show'){
			$( "#policemenu" ).show('slow');
		}else if(event.data.type == 'hide'){
			$( "#policemenu" ).hide('slow'); 
		}
    });
})

function init() {
    $( ".accept" ).click( function() {
		$.post('http://srp_statepolicejob/sendData', JSON.stringify({ charge: $("#charge").val(), money: $("#money").val(), jailTime: $("#jailtime").val(), playerId: $("#playerid").val() }));
    });
	 $( ".exit" ).click( function() {
		$.post('http://srp_statepolicejob/exit', JSON.stringify({}));
    });
}