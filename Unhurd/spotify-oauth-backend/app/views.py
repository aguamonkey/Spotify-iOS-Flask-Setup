from app import app  # Import the 'app' instance from the app package
from flask import request, redirect, jsonify, session
from flask_session import Session  # Flask-Session extension
import requests
import os
from datetime import datetime, timedelta
from urllib.parse import urlencode
from dotenv import load_dotenv

load_dotenv()

app.config['SECRET_KEY'] = os.getenv('FLASK_SECRET_KEY', 'a_default_secret_key')
app.config['SESSION_TYPE'] = 'filesystem'  # Configure session to use the filesystem

# Secure cookies should only be enabled if running over HTTPS in production
#flask_env = os.getenv('FLASK_ENV', 'development')  # Default to 'development' if not set
#if flask_env == 'production':
#    app.config['SESSION_COOKIE_SECURE'] = True
#    app.config['REMEMBER_COOKIE_SECURE'] = True

Session(app)

CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')
CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
LOCAL_REDIRECT_URI = os.getenv('LOCAL_REDIRECT_URI')


@app.route('/')
def index():
    return 'Welcome to the Spotify OAuth Flow!'

@app.route('/login')
def login():
    scope = 'user-read-private'
    auth_params = {
        'client_id': CLIENT_ID,
        'response_type': 'code',
        'redirect_uri': LOCAL_REDIRECT_URI,
        'scope': scope
    }
    auth_url = f"https://accounts.spotify.com/authorize?{urlencode(auth_params)}"
    return redirect(auth_url)

@app.route('/callback')
def callback():
    code = request.args.get('code')
    if not code:
        return jsonify({'error': 'Authorization code not received'}), 400
    
    token_url = 'https://accounts.spotify.com/api/token'
    token_data = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': LOCAL_REDIRECT_URI,
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
    }
    r = requests.post(token_url, data=token_data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    
    if r.status_code != 200:
        return jsonify(r.json()), r.status_code
    
    token_info = r.json()
    session['access_token'] = token_info.get('access_token')
    session['refresh_token'] = token_info.get('refresh_token')
    session['token_expires_at'] = datetime.now() + timedelta(seconds=token_info.get('expires_in'))
    return jsonify(token_info)

@app.route('/api/spotify/refresh_token', methods=['POST'])
def refresh_spotify_token():
    # Extract the refresh token from the request
    refresh_token = request.json.get('refresh_token')
    if not refresh_token:
        return jsonify({"error": "Missing refresh token"}), 400

    # Prepare the request to Spotify's token endpoint
    token_url = "https://accounts.spotify.com/api/token"
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    payload = {
        'grant_type': 'refresh_token',
        'refresh_token': refresh_token,
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
    }

    # Send the request to Spotify
    response = requests.post(token_url, headers=headers, data=payload)
    if response.status_code != 200:
        # Handle error from Spotify
        return jsonify(response.json()), response.status_code

    # Return the new access token (and refresh token if provided) to the iOS app
    return jsonify(response.json())

if __name__ == "__main__":
    app.run(debug=True)
