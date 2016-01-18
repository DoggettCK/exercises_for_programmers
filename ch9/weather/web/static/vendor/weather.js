var GetCurrentWeather = function() {
  var location = $("#location").val();
  var format = $("input[type=radio][name=format]:checked").val();
  
  if (location === "" || location == undefined) return;

  $.post("/api/current_weather", {
    location: location,
    format: format
  }, function(weather_data) {
    alert(JSON.stringify(weather_data))
  });
};

$("#location").on('change propertychange paste', GetCurrentWeather);
$("input[type=radio][name=format]").change(GetCurrentWeather);
GetCurrentWeather();
