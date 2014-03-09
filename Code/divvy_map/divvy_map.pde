//
// LIBRARIES // do we need all deez??
//

import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;

import java.util.Map;
import java.util.Date;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;


//
// GLOBAL VARIABLES & JUNK
//

UnfoldingMap map; // Set up the map
Location chicagoLocation = new Location(41.883, -87.632); // Set map to chicago

String date_1 = "2013-07-13 08:00:00";
String date_2 = "2013-07-13 09:00:00";
String query = "http://data.olab.io/divvy/api.php?&start_min="+ date_1+"&start_max="+date_2;
JSONArray tripsJSON = loadJSONArray(query);
int max_trips = tripsJSON.size(); // PVector Setup: the max trips is the amount of trips we want to get.


PVector[] to_station = new PVector[max_trips];
PVector[] from_station = new PVector[max_trips];
float[] trip_time = new float[max_trips];
String[] start_time = new String[max_trips];
String[] end_time = new String[max_trips];


ArrayList<tripPath> paths = new ArrayList<tripPath>();
ArrayList<Vehicle> bikes = new ArrayList<Vehicle>();
//ArrayList<float> time = new ArrayList<float>();

//
// SETUP
//

void setup() {
  background(120);
  size(800, 600, P2D);
  frameRate(50);
  println(max_trips);
  // map setup
  map = new UnfoldingMap(this, new OpenStreetMap.CloudmadeProvider("07db658f6f5d48148dd007fcace89a16", 124011 ));
  map.zoomAndPanTo(chicagoLocation, 12);
  MapUtils.createDefaultEventDispatcher(this, map);

  // run to get PVectors to_station, from_station
  createPVectors();

  for (int i = 0; i < max_trips; ++i) {
    ScreenPosition from_point = getScreenPositions(from_station[i]);
    ScreenPosition to_point = getScreenPositions(to_station[i]);
    newPath(from_point, to_point);
    // println(from_point.x);
  }
}
//
// DRAW
//

void draw() {
  // draw map
  // map.draw();
  //

  // draws paths to screen
  // for (int i = 0; i < max_trips; ++i) { paths.get(i).display(); }
  //background(255,10);

  newBikes(max_trips);


  for (int i = 0; i < max_trips; ++i) {
    bikes.get(i).follow(paths.get(i));
    // only runs trip if bike is within some distance of end station 
    float distance_left = dist(bikes.get(i).location.x, bikes.get(i).location.y, paths.get(i).getEnd().x, paths.get(i).getEnd().y);
    if (distance_left>10) {
      // Call the generic run method (update, borders, display, etc.)
      bikes.get(i).run();
    }
  }
  fill(220, 40);
  rect(0, 0, width, height);
}

//
// CUSTOM FUNKTIONS
//

void createPVectors() {
  //lets load the stations data!
  JSONArray stationsJSON = loadJSONArray("http://data.olab.io/divvy/stations.json");  
  //through the api, lets load 10 trips!
  // JSONArray tripsJSON = loadJSONArray("http://data.olab.io/divvy/api.php?&start_min=2013-06-27 00:00:00&start_max=2013-06-27 23:59:59&rpp=10");
  JSONArray tripsJSON = loadJSONArray(query);
  //JSONArray tripsJSON = loadJSONArray("http://data.olab.io/divvy/api.php?&page=0&rpp=1");
  //we will now go through all the trips (see api)

  //
  // _Main _for _Loop _. 
  // 
  
  for (int i = 0; i < tripsJSON.size();i++) {    // _Load _Trips _From _query
    //load one trip at a time.
    JSONObject tripJSON = tripsJSON.getJSONObject(i);
    //grab the to_station and from_station data    
    int fromStationID = tripJSON.getInt("from_station_id");
    int toStationID = tripJSON.getInt("to_station_id");

    String start_time = tripJSON.getString("start_time");
    String stop_time = tripJSON.getString("stop_time");

    trip_time[i] = tripDuration(start_time, stop_time); // see dateParse & tripDuration functions below


    //for EVERY trip, load all 300 stations and check to see if trip[i]'s to_station_id matches a station from the stationsJSON,
    //and if so, grab the latitude and longitude data from the stationJSON and add it to the trip[i]
    for (int j = 0; j < stationsJSON.size(); j++) {
      //load station[j]
      JSONObject stationJSON = stationsJSON.getJSONObject(j);

      //grab station id from station[j]
      int currentId = stationJSON.getInt("id");

      //grab the latitude and longitude of station[j]
      float latitude = stationJSON.getFloat("latitude");
      float longitude = stationJSON.getFloat("longitude");  

      //see if the id matches the id from the trip[i] data, then add the coordinates to a PVector
      if (currentId == fromStationID) {
        //create PVector[] with to lat and lon from trip[i]'s from_station[i]
        from_station[i] = new PVector(latitude, longitude, 0.0);
      }
      if (currentId == toStationID) {
        //create PVector[] with lat and lon from trip[i]'s to_station[i]
        to_station[i] = new PVector(latitude, longitude, 0.0);
      }
    }
  }
  //go through new PVectors that store the latitude, longitude and tripduration, though we might not use trip duration.............ttyl
  //since we are going through the PVector[]s at the same time, they match and make a trip. as in from_station[1] matches to to_station[1] in a trip  
  for (int e = 0; e < from_station.length; e++) {
    //println("from station at " + from_station[e].x + ", " + from_station[e].y);
    //println("to station at " + to_station[e].x + ", " + to_station[e].y);
  }
}



// CUSTOM FUNCTION to create a marker and then get it's x,y screenpositions; see unfolding maps docs
ScreenPosition getScreenPositions(PVector station_coordinates) {
  Location station_location = new Location(station_coordinates.x, station_coordinates.y);
  // make a marker
  SimplePointMarker station_marker = new SimplePointMarker(station_location);
  ScreenPosition station_marker_pos = station_marker.getScreenPosition(map);
  return station_marker_pos;
}

// CUSTOM FUNCTION to draw paths from start to end stations on screen; see tripPath class
void newPath(PVector from, PVector to) {
  // A path is a series of connected points
  tripPath path = new tripPath();
  path.addPoint(from.x, from.y);
  path.addPoint(to.x, to.y);
  paths.add(path);
}

// FUNCTION to initialize bikes; see Vehicle class 
void newBikes(int max) {
  for (int i = 0; i<max;++i) {
    // Vehicle( PVector startPoints, float ms, float mf) 
    Vehicle bike = new Vehicle(paths.get(i).getStart(), trip_time[i]*.001, .05); // change the 1 to correspond to trip duration
    bikes.add(bike);
  }
}

// CUSTOM FUNCTION to turn dates String into float; see CUSTOM FUNCTION tripDuration
float dateParse(String date) {
  String[] day = date.split(" ");
  String[] hours_text = day[1].split(":");
  float milisec = (Float.valueOf(hours_text[0])*120)+(Float.valueOf(hours_text[1])*60)+Float.valueOf(hours_text[2]);
  return milisec;
  // println(hours[0]);
}


// CUSTOM FUNCTION to get trip_time; see CUSTOM FUNCTION dateParse
float tripDuration(String start, String stop) {
  float _start = dateParse(start);
  float _stop = dateParse(stop);
  // subtract end time from start
  float time_total = _stop - _start;
  // if negative, make positive
  while (time_total < 0) {
    time_total = time_total *(-1);
  }
  return time_total;
}

