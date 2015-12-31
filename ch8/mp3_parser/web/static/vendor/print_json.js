// string|number|array|regexp|function|date|boolean
function listify (node, obj) {
  var ul = $("<ul>");

  if (obj instanceof Array) {
    $.each(obj, function(x) { listify(ul, obj[x]); });
  } else {
    $.each(obj, function(k, v) {
      if (typeof(v) === 'string' || v instanceof String || typeof(v) === 'number' || v instanceof Number) {
        ul.append(
            $("<li>")
            .append($("<b>").text(k))
            .append($("<span>").text(": " + v)));
      } else {
        var li = $("<li>").append($("<b>").text(k));

        listify(li, v);

        ul.append(li);
      }
    });
  } 

  $(node).append(ul);
}
