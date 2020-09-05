$(function () {
  $("form.delete").submit(function (event) {
    event.preventDefault();
    event.stopPropagation();

    var ok = confirm("Are you sure? This cannot be undone.");
    if (ok) {
      // this.submit();

      var form = $(this); // from assignment: https://launchschool.com/lessons/2c69904e/assignments/94ee8ca2

      var request = $.ajax({
        url: form.attr("action"),
        method: form.attr("method"),
      });

      request.done(function (data, textStatus, jqXHR) {
        if (jqXHR.status === 204) {
          form.parent("li").remove();
        } else if (jqXHR.status === 200) {
          document.location = data;
        }
      });
    }
  });
});
