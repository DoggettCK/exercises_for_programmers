function xbl_image_url (gpd_id, image_id) {
  return "http://image.xboxlive.com/global/t." + gpd_id + "/ach/0/" + image_id.toString(16);
}

function int_to_0x(i) {
  return "0x" + i.toString(16);
}

function parse_gpd_response (node, gpd_json) {
  var gpd_id = gpd_json.gpd_id;
  var gpd = gpd_json.gpd;

  var title_div = $("<h2>").attr({"id": "title"}).text(gpd.title);
  var achievement_count = $("<h3>").text("Achievements Earned: " + (gpd.settings.achievements_earned || 0));
  var total_gs = $("<h3>").text("Gamerscore Earned: " + (gpd.settings.gamerscore_earned || 0));

  $(node).append(title_div, achievement_count, total_gs);
  $.each(gpd.achievements, function(i, ach) { $(node).append(build_achievement_node(gpd_id, ach)); })
}

function build_achievement_node (gpd_id, achievement) {
  var img = $("<img>").attr({"src": xbl_image_url(gpd_id, achievement.image_id)});
  var name = $("<h4>").addClass("name").text(achievement.name + (achievement.flags.secret ? " (SECRET)" : ""));
  var gamerscore = $("<h4>").addClass("gamerscore").text(achievement.gamerscore + "GS");
  var desc = $("<span>").addClass("description").text(achievement.flags.earned ? achievement.unlocked_desc : achievement.locked_desc);
  var unlocked_at = $("<span>").addClass("unlocked_at").text(unlock_date(achievement.unlocked_at, achievement.flags))

  return $("<div>").addClass("achievement").addClass(achievement.flags.earned ? "unlocked" : "locked").append(img, name, gamerscore, desc, unlocked_at);
}

function unlock_date (unlocked_at, flags) {
  if (!flags.earned) {
    return "Not unlocked yet";
  }

  if (flags.earned_online) {
    return "Unlocked on " + filetime_as_string(unlocked_at);
  }
  else {
    return "Unlocked Offline";
  }
}

function filetime_as_string (ft) {
  var s = "" + ft;
  var ts = +s.substring(0, s.length-4);
  var fsOffset = Date.UTC(1601, 0, 1);
  var d = new Date(fsOffset + ts);
  return moment(d).format("dddd MMMM Do YYYY, hh:mm:ss.SSS A z");
}
