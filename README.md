# SmartRubberDucky

**SmartRubberDucky** is a web application UI for an IoT project designed to simulate the functionality of a **Rubber Ducky**. A Rubber Ducky is a USB device that acts as a keyboard and executes pre-programmed scripts on the connected computer. However, SmartRubberDucky uses a microcontroller that connects to WiFi instead of an SD card, enabling the device to fetch scripts from a Firebase Realtime Database. 

The web application allows users to register, log in, and interact with multiple Rubber Ducky devices by using device IDs. Scripts can be saved, edited, executed, and deleted directly from the web UI.

---

## Features

- **User Authentication**: 
  - Sign up and sign in using Firebase Authentication.
  - Users can maintain their sessions across page reloads.

- **Device ID Management**:
  - Each microcontroller has a unique hardcoded device ID.
  - Users can input the device ID on the home page to interact with different Rubber Ducky devices easily.

- **Saved Scripts**:
  - Users can save, edit, delete, and execute scripts on their Rubber Ducky devices.
  - Scripts are stored in Firebase Firestore under each user’s collection.
  - Scripts can be executed on connected devices by sending the script to a backend server.

- **User-Friendly Interface**:
  - Responsive UI built with Flutter, with sections for:
    - Register/Login.
    - Home page with device ID input.
    - Saved scripts management.
  - Customizable themes and styling to enhance the user experience.

---

## Firebase Integration

This project uses Firebase for both authentication and storing data:

1. **Authentication**: Users can sign up or log in using Firebase Authentication (Email/Password).
2. **Firestore**: Stores the user’s saved scripts in Firestore for easy retrieval, modification, and deletion.
3. **Realtime Database**: Facilitates the execution of commands on the microcontroller and stores execution responses.

### Firebase Realtime Database Structure

The Firebase Realtime Database stores both the **commands** to be executed and the **responses** after execution, organized by device ID. Each device has its own section in the database:

#### Command Structure (Before Execution):
Each device stores the commands it needs to execute in the **commands** node, with a timestamp to track when the command was added.

Example:

```json
{
  "devices": {
    "device_001": {
      "commands": {
        "command": "GUI r",
        "timestamp": 1730387728
      }
    }
  }
}
```

In this state, the microcontroller reads the command, executes it, and then deletes the command.

### Response Structure (After Execution):
Once the microcontroller executes the command, it stores the response in the `responses` node, along with a timestamp. The response indicates whether the command was executed successfully.

#### Example:

```json
{
  "devices": {
    "device_001": {
      "responses": {
        "response": "Execution completed successfully.",
        "timestamp": 1577836860
      }
    }
  }
}
```

After the command is executed, it is removed from the `commands` node, and the microcontroller sends a response, which is stored in the `responses` node for tracking.

This is a concise, clear explanation of the Firebase integration, how authentication works, how scripts are stored in Firestore, and how the Realtime Database is used for command execution and response tracking.

