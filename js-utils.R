# popovers
# popoverInit <- function() {
#   tags$head(
#     tags$script(
#       "$(document).ready(function(){
#       $('body').popover({
#       selector: '[data-toggle=\"popover\"]',
#       trigger: 'hover'        
#       });});"
#     )
#   )
# }
# 
# popover <- function(content, pos, ...) {
#   tagList(
#     singleton(popoverInit()),
#     tags$a(href = "#", `data-toggle` = "popover", `data-placement` = paste("auto", pos),
#            `data-original-title` = "", title = "", `data-trigger` = "hover",
#            `data-html` = "true", `data-content` = content, ...)
#   )
# }

popoverInit <- function() {
  tags$head(
    tags$script(
      "$(document).ready(function(){
      $('body').popover({
      selector: '[data-toggle=\"popover\"]',
      trigger: 'click'        
      });});
      "
    ),
    tags$script(
      # This solution taken directly from stackover question 11703093
      # Conditional logic modified slightly as ampersands were not readily escaped
      "
      $(document).on(
        'click',
        function (e) {
          $('[data-toggle=\"popover\"],[data-original-title]').each(function () {
            //the 'is' for buttons that trigger popups
            //the 'has' for icons within a button that triggers a popup
            if (!$(this).is(e.target)) {
              if($(this).has(e.target).length === 0) {
                if($('.popover').has(e.target).length === 0) {                
                  (($(this).popover('hide').data('bs.popover')||{}).inState||{}).click = false  // fix for BS 3.3.6
                }
              }
            }
          });
        });
      "
    )
  )
}

popover <- function(content, pos, ...) {
  tagList(
    singleton(clickPopoverInit()),
    tags$a(href = "#", `data-toggle` = "popover", `data-placement` = paste("auto", pos),
           `data-original-title` = "", title = "", `data-trigger` = "click",
           `data-html` = "true", `data-content` = content, ...)
  )
}

# proxy click on enter
proxyclickInit <- function() {
  tags$head(
    tags$script(
      HTML(
        '
        $(function() {
          var $els = $("[data-proxy-click]");
          $.each(
            $els,
            function(idx, el) {
              var $el = $(el);
              var $proxy = $("#" + $el.data("proxyClick"));
              $el.keydown(function (e) {
                if (e.keyCode == 13) {
                  $proxy.click();
                }
              });
            }
          );
        });
        '
      )
    )
  )
}

