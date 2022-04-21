//----------------------------------//
//             LEO HN               //
//   https://github.com/Hubbit200   //
//----------------------------------//

import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

JFileChooser chooser = new JFileChooser();
FileNameExtensionFilter filter = new FileNameExtensionFilter("JSON", "json");

JSONArray data;
JSONArray output = new JSONArray();

int state = 0, editing = 0;
String username = "", otherUsername = "", filePath = "";
String dataString, searchTag="";

PImage background;

void setup() {
  size(700, 400);
  background(255);
  textSize(25);
  rectMode(CORNERS);
  textAlign(LEFT, CENTER);
  noStroke();
  background = loadImage("fondoinstagramrubbishremoveador.png");
  chooser.setFileFilter(filter);
}

void draw() {
  if (state == 0) {
    background(background);
    background(background);
    
    // Draw username boxes
    if (editing == 0)fill(#FAFAF7);
    else fill(#F2EF90);
    rect(240, 40, 680, 85, 10);
    fill(#FFFFFF);
    text("Your username:", 25, 45, 240, 80);
    fill(0);
    text(username, 245, 40, 675, 80);

    if (editing == 1)fill(#FAFAF7);
    else fill(#F2EF90);
    rect(240, 125, 680, 170, 10);
    fill(#FFFFFF);
    text("Other username:", 25, 125, 240, 160);
    fill(0);
    text(otherUsername, 245, 125, 675, 170);

    // Draw file selection
    if (editing == 2)fill(#FAFAF7);
    else fill(#F2EF90);
    rect(25, 255, 680, 295, 10);
    if (mouseX > 500 && mouseX < 680 && mouseY > 205 && mouseY < 250)fill(#6678E5);
    else fill(#6D9AFA);
    rect(500, 205, 680, 250, 10);
    fill(#FFFFFF);
    text("Filepath (messages.json): ", 25, 205, 500, 245);
    textAlign(CENTER, CENTER);
    text("SELECT", 505, 200, 670, 250);
    textAlign(LEFT, CENTER);
    textSize(15);
    fill(0);
    text(filePath, 35, 255, 675, 290);
    textSize(25);

    // Draw Start button
    if (mouseX > width/2-100 && mouseX < width/2+100 && mouseY > 310 && mouseY < 380 && filePath != "" && username != "" && otherUsername != "")fill(#6678E5);
    else if (filePath != "" && username != "" && otherUsername != "")fill(#6D9AFA);
    else fill(180);
    rect(width/2-100, 310, width/2+100, 380, 10);
    textAlign(CENTER, CENTER);
    fill(#FFFFFF);
    text("START", width/2-100, 310, width/2+100, 375);
    textAlign(LEFT, CENTER);
    
  // Draw Export complete screen
  } else if (state == 1) {
    textAlign(CENTER,CENTER);
    background(background);
    textSize(40);
    text("Export complete!", width/2, height/2);
  }
}

void processData() {
  JSONObject dm = data.getJSONObject(0);
  boolean found = false;

  // Check usernames
  for (int i = 0; i < data.size(); i++) {
    dm = data.getJSONObject(i);
    if (dm.getJSONArray("participants").get(0).toString().equals(otherUsername) == true && dm.getJSONArray("participants").get(1).toString().equals(username) == true) {
      found = true;
      break;
    }
  }
  if (found) {
    // Cycle through messages, fix formatting and add to new JSON array
    JSONArray conversations = dm.getJSONArray("conversation");
    for (int j = 0; j < conversations.size(); j++) {
      JSONObject message = new JSONObject();
      message.setString("sender", conversations.getJSONObject(j).get("sender").toString());
      if (conversations.getJSONObject(j).get("text") != null)message.setString("message", conversations.getJSONObject(j).get("text").toString());
      else message.setString("message", "POST - NOT YET SUPPORTED");
      output.setJSONObject(conversations.size()-1-j, message);
    }
    
    // Save output file
    int returnVal = chooser.showSaveDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      println(chooser.getSelectedFile().getAbsolutePath().substring(chooser.getSelectedFile().getAbsolutePath().length()-5,chooser.getSelectedFile().getAbsolutePath().length()));
      if (chooser.getSelectedFile().getAbsolutePath().substring(chooser.getSelectedFile().getAbsolutePath().length()-5,chooser.getSelectedFile().getAbsolutePath().length()).matches(".json"))saveJSONArray(output, chooser.getSelectedFile().getAbsolutePath());
      else saveJSONArray(output, chooser.getSelectedFile().getAbsolutePath()+".json");
    }

    searchTag = "Exported!";
  }
}

void mouseClicked() {
  if (state == 0) {
    // Text boxes
    if (mouseY > 40 && mouseY < 85) {
      editing = 0;
    } else if (mouseY > 120 && mouseY < 165) {
      editing = 1;
    } else if (mouseY > 255 && mouseY < 295) {
      editing = 2;
    // File select button
    } else if (mouseX > 500 && mouseY > 205 && mouseX < 680 && mouseY < 250) {
      int returnVal = chooser.showOpenDialog(null);
      if (returnVal == JFileChooser.APPROVE_OPTION) {
        filePath = chooser.getSelectedFile().getAbsolutePath();
      }
    // Start button
    } else if (mouseY > 300 && mouseX > width/2-100 && mouseX < width/2+100 && username != "" && otherUsername != "" && filePath != "") {
      data = loadJSONArray(filePath);
      state=1;
      processData();
    }
  }
}

// Text input
void keyPressed() {
  if (state == 0) {
    if (editing == 0) {
      if (keyCode != 8 && keyCode > 48 && keyCode < 90)username += key;
      else if (username.length() > 0 && keyCode == 8)username = username.substring(0, username.length()-1);
    } else if (editing == 1) {
      if (keyCode != 8 && keyCode > 48 && keyCode < 90)otherUsername += key;
      else if (otherUsername.length() > 0 && keyCode == 8)otherUsername = otherUsername.substring(0, otherUsername.length()-1);
    } else if (editing == 2) {
      if (keyCode != 8 && ((keyCode > 48 && keyCode < 90) || (keyCode == '.')))filePath += key;
      else if (filePath.length() > 0 && keyCode == 8)filePath = filePath.substring(0, filePath.length()-1);
    }
  }
}
