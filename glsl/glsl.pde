// Requires https://github.com/hamoid/video_export_processing
import com.hamoid.*;

PShader shader;
VideoExport videoExport;

ShaderData shaderData;

// !! CHANGE THESE: initial padding frames, final padding frames, animation frames, frame to take the thumbnail on
final int PADDING_START = 30;
final int PADDING_END = 30;
final int FRAMES = 720;
final int THUMBNAIL_FRAME = 300;

boolean enabled = false;
boolean thumbnail = false;
int timestep = 0;

void setup() {
    // !! CHANGE THIS: resolution
    size(2160, 2160, P2D);
    // !! CHANGE THIS: shader to load (from ShaderData.pde)
    shaderData = new JuliaSets();
    shader = shaderData.load();
    shader.set("resolution", float(width), float(height));
    shader.set("pmin", -2.0, -2.0);
    shader.set("pmax", 2.0, 2.0);
}

void draw() {
    if(thumbnail) {
        timestep = PADDING_START + THUMBNAIL_FRAME;
    }
    float shaderTimestep = constrain(timestep-PADDING_START, 0, FRAMES);
    
    shaderData.tick(shaderTimestep);

    shader(shader);
    rect(0, 0, width, height);
    resetShader();

    if(!thumbnail) {
        shaderData.overlay(shaderTimestep);
    }

    if(enabled) {
        videoExport.saveFrame();
        if(timestep > FRAMES + PADDING_START + PADDING_END) {
            enabled = false;
            videoExport.endMovie();
            exit();
        }
        timestep += 1;
    }

    if(thumbnail) {
        save("thumbnail.png");
    }

    print(shaderTimestep);
}

void keyPressed() {
    if(key == ' ' && !enabled) {
        // Space: start recording
        timestep = 0;
        videoExport = new VideoExport(this);
        videoExport.startMovie();
        enabled = true;
        println("Starting...");
    } else if(key == 't' && !enabled) {
        // t: save thumbnail
        thumbnail = true;
    }
}
