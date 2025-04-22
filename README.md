# MyShaders

Welcome to the **MyShaders** repository! This project is a collection of custom shaders created and maintained by **Dharmesh**.

## About the Project

This repository contains various shader programs designed for graphics rendering and visual effects. These shaders are written to enhance graphical applications and provide creative visual solutions.

## Author

- **Name**: Dharmesh
- **GitHub Profile**: [Dharmesh](https://github.com/Dharmesh-IT) 

## Features

- Custom shader programs for different use cases.
- Easy-to-integrate solutions for graphics projects.
- Regular updates and improvements.

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Dharmesh-IT/myshaders.git
   ```
2. Explore the shaders and integrate them into your projects.

## Usage in Windows Terminal

You can use shaders to customize the appearance of your Windows Terminal by applying effects to the terminal background or text rendering. Below is an example of how to integrate a shader into a Windows Terminal profile using a custom rendering engine:

### Sample Code

```json
// filepath: settings.json
{
  "profiles": {
    "list": [
      {
        "name": "MyShaders Profile",
        "commandline": "cmd.exe",
        "startingDirectory": "%USERPROFILE%",
        "backgroundImage": "path/to/your/shader/output.png",
        "backgroundImageOpacity": 0.8,
        "backgroundImageStretchMode": "fill"
      }
    ]
  }
}
```

### Steps to Use:

1. Render the shader output to an image file (e.g., `output.png`) using your shader program.
2. Update the `settings.json` file of Windows Terminal:
   - Open Windows Terminal.
   - Go to **Settings** > **Open JSON file**.
   - Add a new profile or modify an existing one to include the `backgroundImage` property pointing to the shader output.
3. Save the `settings.json` file and restart Windows Terminal to see the changes.

## Contributing

Contributions are welcome! Feel free to fork the repository, make changes, and submit a pull request.

## License

This project is licensed under the **WTFPL** (Do What The F\*\*\* You Want To Public License). See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or suggestions, feel free to reach out via GitHub.
