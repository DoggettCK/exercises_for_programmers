var GetCurrentWeather = function() {
  var location = $("#location").val();
  var units = $("input[type=radio][name=units]:checked").val();
  
  if (location === "" || location == undefined) return;

  $.post("/api/current_weather", {
    location: location,
    units: units
  }, function(weather_data) {
    var location = $("<h3>")
      .attr({"class": "row"})
      .text( weather_data.location + " Weather");

    var conditions = $("<div>").attr({"class": "row"})
      .append(
          $("<p>").text(weather_data.conditions)
          .append($("<img>").attr({"src": weather_data.icon})));

    var current_temperature = $("<div>")
      .attr({"id": "current_temp", "class": "row"})
      .append(
          $("<label>").text("Current Temperature"),
          $("<span>").text(weather_data.temperature.current));

    var min_temperature = $("<div>")
      .attr({"id": "min_temp", "class": "row"})
      .append(
          $("<label>").text("Low"),
          $("<span>").text(weather_data.temperature.min));

    var max_temperature = $("<div>")
      .attr({"id": "max_temp", "class": "row"})
      .append(
          $("<label>").text("High"),
          $("<span>").text(weather_data.temperature.max));

    var sunrise = $("<div>")
      .attr({"id": "sunrise", "class": "row"})
      .append(
          $("<label>").text("Sunrise"),
          $("<span>").text(moment(weather_data.sun.sunrise * 1000).format("hh:mm:ss A")));

    var sunset = $("<div>")
      .attr({"id": "sunset", "class": "row"})
      .append(
          $("<label>").text("Sunset"),
          $("<span>").text(moment(weather_data.sun.sunset * 1000).format("hh:mm:ss A")));

    var wind = $("<div>")
      .attr({"id": "wind", "class": "row"})
      .append(
          $("<label>").text("Wind"),
          $("<span>").text(weather_data.wind.speed + " " + weather_data.wind.direction));

    var humidity = $("<div>")
      .attr({"id": "humidity", "class": "row"})
      .append(
          $("<label>").text("Humidity"),
          $("<span>").text(weather_data.humidity));

    var pressure = $("<div>")
      .attr({"id": "pressure", "class": "row"})
      .append(
          $("<label>").text("Pressure"),
          $("<span>").text(weather_data.pressure));

    $("#weather").empty().append(location, conditions, current_temperature, min_temperature, max_temperature, sunrise, sunset, wind, humidity, pressure);
  });
};

$("#location").on('change propertychange paste', GetCurrentWeather);
$("input[type=radio][name=units]").change(GetCurrentWeather);
GetCurrentWeather();
