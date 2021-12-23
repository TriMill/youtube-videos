public interface ShaderData {
    // Load the shader from file
    public PShader load();
    // Run before the shader: set the shader's uniforms
    public void tick(float time);
    // Run after the shader: draw things on top (ex. text)
    public void overlay(float time);
}

class JuliaSets implements ShaderData {
    private PShader shader = null;
    private float re, im;

    public PShader load() {
        if(shader == null) {
            shader = loadShader("juliasets.glsl");
        }
        return shader;
    }
    public void tick(float time) {
        // Unit circle
        //re = cos(time*TAU/FRAMES);
        //im = sin(time*TAU/FRAMES);

        // Main cardioid
        //float t = time*TAU/FRAMES/2.;
        //re = 0.25*(2*cos(t) - cos(2*t));
        //im = 0.25*(2*sin(t) - sin(2*t));

        // Real axis
        //re = map(time, 0, FRAMES, -2, 1);
        //im = 0;

        // Seahorse valley
        re = -0.75;
        im = map(time, 0, FRAMES, -2, 1);

        shader.set("cvalue", re, im);
    }
    public void overlay(float time) {
        fill(0);
        noStroke();
        textSize(50);
        text("c = " + String.format("%.4f", re) + " + " + String.format("%.4f", im) + "i", 20, 60);
    }
}

class MandelbrotTransformation implements ShaderData {
    private PShader shader = null;

    public PShader load() {
        if(shader == null) {
            shader = loadShader("mandelbrot_transformation.glsl");
        }
        return shader;
    }
    public void tick(float time) {
        shader.set("time", time/FRAMES);
    }
    public void overlay(float time) {}
}
