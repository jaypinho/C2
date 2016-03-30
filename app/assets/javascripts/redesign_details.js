(function(){

  var details_app = details_app || {};

  details_app.blastOff = function(){
    this.setup_status_toggle();
  }

  details_app.setup_status_toggle = function(){
    $('.status-toggle-all').on('click', function(e){
      e.preventDefault();
      $('.status-contracted').toggleClass('status-expanded');
      if($('.status-contracted').hasClass('status-expanded')){
        $('.status-toggle-all').text('Minimize');
      } else {
        $('.status-toggle-all').text('Show all');
      }
    });
  }

  $(document).ready(function(){
    details_app.blastOff();
  });

})();