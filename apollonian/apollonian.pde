import java.util.PriorityQueue;
import java.util.TimeZone;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;

// Requires https://github.com/hamoid/video_export_processing
import com.hamoid.*;

class Circle {
    public double x, y, r;
    public Circle(double x, double y, double r) {
        this.x = x; this.y = y; this.r = r;
    }
}

class Triple implements Comparable<Triple> {
    public int a, b, c;
    public Triple(int a, int b, int c) {
        this.a = a; this.b = b; this.c = c;
    }

    public double getOrdering(ArrayList<Circle> circles) {
        double k1 = 1/circles.get(a).r;
        double k2 = 1/circles.get(b).r;
        double k3 = 1/circles.get(c).r;
        double root = 2*Math.sqrt(k1*k2 + k2*k3 + k3*k1);
        double k4a = (k1 + k2 + k3) - root;
        double k4b = (k1 + k2 + k3) + root;
        return Math.max(k4a, k4b);
    }

    public int compareTo(Triple t) {
        return Double.compare(this.getOrdering(circles), t.getOrdering(circles));
    }
}

ArrayList<Circle> circles;
PriorityQueue<Triple> nextTriples;

//PImage img;

VideoExport videoExport;

void setup() {
    size(2160, 2160);
    //img = loadImage("image.png");
    ellipseMode(RADIUS);
    imageMode(CENTER);
    videoExport = new VideoExport(this);
    videoExport.startMovie();

    circles = new ArrayList<>();
    nextTriples = new PriorityQueue<>();

    /* Animation: increasing circle count over time */
    //circles.add(new Circle(0, 0, -1));
    //circles.add(new Circle(2.0/3, 0, 1.0/3));
    //circles.add(new Circle(-1.0/3, 0, 2.0/3));
    //circles.add(new Circle(3.0/7, 4.0/7, 2.0/7));
    //circles.add(new Circle(3.0/7, -4.0/7, 2.0/7));
    //nextTriples.add(new Triple(0, 1, 3));
    //nextTriples.add(new Triple(0, 1, 4));
    //nextTriples.add(new Triple(0, 2, 3));
    //nextTriples.add(new Triple(0, 2, 4));
    //nextTriples.add(new Triple(1, 2, 3));
    //nextTriples.add(new Triple(1, 2, 4));

    //for(int i = 0; i < 20000; i++) {
    //    nextCircle();
    //}
}

float sc = 8*width;

/* Animation: changing ratio of two main circles */
double x0 = -1;

void draw() {
    background(0);
    stroke(255);
    noFill();
    translate(width/2., height/2.);
    strokeWeight(1.0);
    
    /* Animation: changing ratio of two main circles */

    circles.clear();
    nextTriples.clear();

    circles.add(new Circle(0, 0, -1));
    circles.add(new Circle((x0-1)/2, 0, (1+x0)/2));
    circles.add(new Circle((x0+1)/2, 0, (1-x0)/2));
    Circle initCircle = new Circle(4*x0/(3+x0*x0), 2*(1-x0*x0)/(3+x0*x0), (1-x0*x0)/(3+x0*x0));
    circles.add(initCircle);
    circles.add(new Circle(initCircle.x, -initCircle.y, initCircle.r));
    nextTriples.add(new Triple(0, 1, 3));
    nextTriples.add(new Triple(0, 1, 4));
    nextTriples.add(new Triple(0, 2, 3));
    nextTriples.add(new Triple(0, 2, 4));
    nextTriples.add(new Triple(1, 2, 3));
    nextTriples.add(new Triple(1, 2, 4));

    for(int i = 0; i < 4000; i++) {
        nextCircle();
    }
    for(Circle c: circles) {
        float x = (float)(c.x) * sc;
        float y = (float)(c.y) * sc;
        float r = (float)(c.r) * sc;
        /* Display: draw circles */
        //if(r < 1) {
        //    strokeWeight(0.5);
        //} else {
        //    strokeWeight(1);
        //}
        ellipse(x, y, r, r);
        /* Display: show image instead of circles */
        //if(r > 0) {
        //    image(img, x, y, 2*r, 2*r);
        //    pushMatrix();
        //    translate(x, y);
        //    rotate(random(1)*TAU);
        //    image(img, 0, 0, 2*r, 2*r);
        //    popMatrix();
        //}
    }

    /* Animation: increasing circle count over time */

    //for(int i = 0; i < 200; i++) {
    //    nextCircle();
    //}

    videoExport.saveFrame();

    /* Animation: changing ratio of two main circles */
    x0 += 0.005;

    if(x0 > 1) {
        videoExport.endMovie();
        exit();
    }
}

void mouseClicked() {
    TimeZone tz = TimeZone.getTimeZone("UTC");
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd_HH:mm:ss");
    df.setTimeZone(tz);
    String iso = df.format(new Date());
    String name = "image-" + iso + ".png";
    save(name);
    println("saved as " + name);
}

void nextCircle() {
    Triple next = nextTriples.poll();
    Circle c1 = circles.get(next.a);
    Circle c2 = circles.get(next.b);
    Circle c3 = circles.get(next.c);
    int nextIdx = circles.size();
    Circle cNew = solveApollonius(c1, c2, c3);
    circles.add(cNew);
    nextTriples.add(new Triple(nextIdx, next.a, next.b));
    nextTriples.add(new Triple(nextIdx, next.b, next.c));
    nextTriples.add(new Triple(nextIdx, next.c, next.a));
}

Circle solveApollonius(Circle c1, Circle c2, Circle c3) {
    Circle t = trySolveApollonius(c1, c2, c3);
    if(Double.isNaN(t.r)) {
        t = trySolveApollonius(c2, c1, c3);
        if(Double.isNaN(t.r)) {
            t = trySolveApollonius(c1, c3, c2);
        }
    }
    return t;
}

// From https://rasmusfonseca.github.io/implementations/apollonius.html
Circle trySolveApollonius(Circle c1, Circle c2, Circle c3) {
    double x1 = c1.x;
    double y1 = c1.y;
    double r1 = c1.r;
    double x2 = c2.x;
    double y2 = c2.y;
    double r2 = c2.r;
    double x3 = c3.x;
    double y3 = c3.y;
    double r3 = c3.r;

    double v11 = 2*x2 - 2*x1;
    double v12 = 2*y2 - 2*y1;
    double v13 = x1*x1 - x2*x2 + y1*y1 - y2*y2 - r1*r1 + r2*r2;
    double v14 = 2*r2 - 2*r1;

    double v21 = 2*x3 - 2*x2;
    double v22 = 2*y3 - 2*y2;
    double v23 = x2*x2 - x3*x3 + y2*y2 - y3*y3 - r2*r2 + r3*r3;
    double v24 = 2*r3 - 2*r2;

    double w12 = v12/v11;
    double w13 = v13/v11;
    double w14 = v14/v11;

    double w22 = v22/v21-w12;
    double w23 = v23/v21-w13;
    double w24 = v24/v21-w14;

    double P = -w23/w22;
    double Q = w24/w22;
    double M = -w12*P-w13;
    double N = w14 - w12*Q;

    double a = N*N + Q*Q - 1;
    double b = 2*M*N - 2*N*x1 + 2*P*Q - 2*Q*y1 + 2*r1;
    double c = x1*x1 + M*M - 2*M*x1 + P*P + y1*y1 - 2*P*y1 - r1*r1;

    // Find roots of a quadratic equation

    double rs = (-b + Math.sqrt(b*b - 4*a*c))/(2*a);
    double xs = M+N*rs;
    double ys = P+Q*rs;

    return new Circle(xs, ys, Math.abs(rs));
}
