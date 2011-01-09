var weekday_short = new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
var month_short = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");

//////////////////////////////////////
// TABS
// courtesy Yehuda Katz
//
$("ul.tabs").live("click", function(event){
  var selected = $(event.target);
  var pane = $(selected.paneSelector());

  if (selected.is("ul")) return;

  $(this)
    .data("pane")
    .hide();

  selected
    .addClass("selected")
    .siblings()
    .removeClass("selected");

  $(this)
    .data("pane", pane)
    .data("selected", selected);

  pane
    .show()
    .focusable();

  $(this).trigger("change");
});


$(function(){
  $("ul.tabs").each(function(){
    var set = [];

    $(this).find("li").each(function(){
      set.push($(this).paneSelector());
    });

    $(this)
      .data("pane", $(set.join(",")))
      .find("li.selected")
      .click();
  });

  $(document).focusable();
});


$.fn.extend({
  paneSelector: function(){
    return "div#" + $(this).attr("data-pane");
  },
  focusable: function(){
    $(this).find("*:visible.focusable:first").focus();
  }
});


function hideTab(pane){
  $("ul.tabs li[data-pane=" + pane + "]").hide();
}
function showTab(pane){
  $("ul.tabs li[data-pane=" + pane + "]").show();
}


function ajaxSpinner(){
  var spinner = $(document.createElement("img"));
  spinner
    .attr("class", "ajax-spinner")
    .attr("src", "/images/ajax/spinner3-bluey.gif")
    .attr("alt", "");
  return spinner;
}