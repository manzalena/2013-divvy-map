// This class was made using PathFollowing example from The Nature of Code by Daniel Shiffman // http://natureofcode.com


class tripPath {

  // A Path is an arraylist of points (PVector objects)
  ArrayList<PVector> points;
  // A path has a radius, i.e how far is it ok for the boid to wander off
  float radius; // could be tripduration

  tripPath() {
    // Arbitrary radius of 20
    radius = 5;
    points = new ArrayList<PVector>();
  }

  // Add a point to the path
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }

  PVector getStart() {
    return points.get(0);
  }

  PVector getEnd() {
    return points.get(points.size()-1);
  }


  // Draw the path
  void display() {
    // Draw thick line for radius
    stroke(1);
    strokeWeight(1);
    noFill();
    beginShape(LINES);
    for (PVector v : points) {
      vertex(v.x, v.y);
    }
    endShape();
    // Draw thin line for center of path
    stroke(0);
    strokeWeight(1);
    noFill();
    beginShape(LINES);
    for (PVector v : points) {
      vertex(v.x, v.y);
    }
    endShape();
  }
}

