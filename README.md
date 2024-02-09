
# Spotify OAuth Integration - Server And App Setup Instructions

This guide focuses on setting up the server component of the Spotify OAuth integration project, ensuring that you can run the app both on real devices and simulators.

## Server Setup

### Prerequisites

- Python 3.6 or newer installed on your machine.
- A local or remote server capable of running Flask applications.

### 1. Clone the Project Repository

First, clone the project repository to your local machine:

```shell
git clone https://github.com/your-repository/spotify-oauth-example.git
cd spotify-oauth-example
```

### 2. Virtual Environment Setup

Create and activate a virtual environment for your project:

```shell
# For macOS/Linux
python3 -m venv venv
source venv/bin/activate

# For Windows
python -m venv venv
.env\Scriptsctivate
```

### 3. Install Requirements

Install the necessary Python packages from `requirements.txt`:

```shell
pip install -r requirements.txt
```

### 4. Environment Configuration

Create a `.env` file in your project root with the following variables:

```plaintext
FLASK_SECRET_KEY=your_flask_secret_key_here
SPOTIFY_CLIENT_ID=your_spotify_client_id_here
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret_here
LOCAL_REDIRECT_URI=http://127.0.0.1:5000/callback # Use your actual redirect URI
```

### Running the Server

To start the Flask server, run:

```shell
python server.py
```

This will start the server on `http://127.0.0.1:5000/`. If running on a real device, replace `127.0.0.1` with your local network IP address (e.g., `192.168.1.x`).

## iOS App Configuration

### Adjusting `info.plist` for Network Permissions

Modify your iOS app's `info.plist` to allow network requests:

1. **Allow Arbitrary Loads**: Under `NSAppTransportSecurity`, set `NSAllowsArbitraryLoads` to `YES` for development purposes.
2. **Specify Exception Domains**: If using specific domains, add them under `NSExceptionDomains`.

### Update IP Address Throughout the Code

Ensure all network request URLs in your iOS code match the server's IP address you're running on:

- Use `http://127.0.0.1:5000/` for simulator testing.
- Replace `127.0.0.1` with your machine's local network IP when testing on real devices.

### Running the App on Simulator vs. Real Device

- **Simulator**: Ensure the server's `LOCAL_REDIRECT_URI` and iOS app network requests use `127.0.0.1`.
- **Real Device**: Use your local network IP address (e.g., `192.168.1.x`). Ensure your device is connected to the same network as your server.

## Conclusion

Following these instructions will set up the server for your Spotify OAuth integration project and configure your iOS app for both simulator and real device testing.
