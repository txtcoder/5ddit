(function() {
  var start, update, setComment;

  start = function() {
    $.ajax({
      type: 'GET',
      url: '/news/index?cache=true',
      async: true,
      success: function(result) {
        console.log("before update");
        $('table').replaceWith(result);
        console.log("after update");
        setComment();
      }
    });
  };

  toggleComment = function(i) {
        var target = "comment"+i;
        var source = "showcomment"+i;
        if (document.getElementById(source).innerText == "show comment") {
            document.getElementById(source).innerText = "hide comment";
            document.getElementById(target).style.display = "block";
        } else {
            document.getElementById(source).innerText = "show comment";
            document.getElementById(target).style.display = "none";
        }
    };

 function toggleCommentDelegate(i) {
    return function() {
        toggleComment(i);
    }
  }
  setComment = function(){
    for (i=0; i < 5; i++) {
        document.getElementById("showcomment"+i).addEventListener("click", toggleCommentDelegate(i));
        document.getElementById("showcomment"+i).style.color="#428bca";
    }
};


  update = function() {
    var x;
    //setComment();
    x = setInterval(start, 600 * 1000);
    start();
  };

    
  $(document).ready(update());
}).call(this);

