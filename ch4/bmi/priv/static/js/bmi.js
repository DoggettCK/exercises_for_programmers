var CalculateBMI = function() {
  $.post("/api/bmi", {
      weight: weight.getValue(),
      height: height.getValue(),
      style: $("input[name=style]:checked").val()
    }, function(bmi_data) {
        var status = bmi_data['status'];
        var bmi = bmi_data['bmi'];
    
        var outcome = "You are within the ideal weight range.";
        var color = "#88ff88";
    
        switch (status) {
              case "underweight":
              case "overweight": 
                outcome = "You are " + status + ". You should see your doctor.";
                color = "#ff8888";
                break;
            }
    
        $("#bmi")
          .html("Your BMI is " + bmi.toFixed(2) + ".<br/>" + outcome)
          .css("background-color", color);
      });
};

var UpdateWeight = function() {
  var weightVal = weight.getValue();

  var unit = 'pounds';

  if ('metric' === $("input[name=style]:checked").val()) {
      unit = 'kilograms';
    }

  $("#weightVal").text(weightVal + ' ' + unit);
};

var UpdateHeight = function() {
  var heightVal = height.getValue();
  
  var bigUnit = "ft";
  var smallUnit = "in";
  var mod = 12;

  if ('metric' === $("input[name=style]:checked").val()) {
      bigUnit = "m";
      smallUnit = "cm";
      mod = 100;
    }

  var big = Math.floor(heightVal / mod);
  var small = Math.floor(heightVal % mod);

  $("#heightVal").text([big, bigUnit, small, smallUnit].join(' '));
};

var weight = $("#weight").slider({
  min: 0,
  max: 1000,
  value: 180,
  tooltip: 'hide'})
.on("change", CalculateBMI)
.on("change", UpdateWeight)
.data('slider');

var height = $("#height").slider({
  min: 1,
  max: 120,
  value: 72,
  tooltip: 'hide'})
.on("change", CalculateBMI)
.on("change", UpdateHeight)
.data('slider');

$("input[type=radio][name=style]").change(function() {
  var currentWeight = $("#weight").slider("getValue");
  var currentHeight = $("#height").slider("getValue");

  if (this.value === 'imperial') {
      $("#weight")
        .slider('setAttribute', 'max', 1000)
        .slider("setAttribute", "value", currentWeight / 0.45359)
        .slider('refresh');
      $("#height")
        .slider('setAttribute', 'max', 120)
        .slider("setAttribute", "value", currentHeight / 2.54)
        .slider('refresh');
    } else {
        $("#weight")
          .slider('setAttribute', 'max', 453)
          .slider("setAttribute", "value", currentWeight * 0.45359)
          .slider('refresh');
        $("#height")
          .slider('setAttribute', 'max', 305)
          .slider("setAttribute", "value", currentHeight * 2.54)
          .slider('refresh');
      }

  UpdateWeight();
  UpdateHeight();
});

CalculateBMI();
UpdateWeight();
UpdateHeight();
