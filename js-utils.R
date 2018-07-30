# popovers
popoverInit <- function() {
  tags$head(
    tags$script(
      "$(document).ready(function(){
      $('body').popover({
      selector: '[data-toggle=\"popover\"]',
      trigger: 'hover'        
      });});"
    )
  )
}

popover <- function(content, pos, ...) {
  tagList(
    singleton(popoverInit()),
    tags$a(href = "#pop", `data-toggle` = "popover", `data-placement` = paste("auto", pos),
           `data-original-title` = "", title = "", `data-trigger` = "hover",
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

