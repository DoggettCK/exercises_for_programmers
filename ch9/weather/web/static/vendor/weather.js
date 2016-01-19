var GetCurrentWeather = function() {
  var location = $("#location").val();
  var units = $("input[type=radio][name=units]:checked").val();
  
  if (location === "" || location == undefined) return;

  $.post("/api/current_weather", {
    location: location,
    units: units
  }, function(weather_data) {
    // TODO: Finish displaying weather
    alert(JSON.stringify(weather_data))
  });
};

$("#location").on('change propertychange paste', GetCurrentWeather);
$("input[type=radio][name=units]").change(GetCurrentWeather);
GetCurrentWeather();
