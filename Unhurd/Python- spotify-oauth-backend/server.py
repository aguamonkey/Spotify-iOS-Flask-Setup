# server.py
from app import app
import logging
app.logger.setLevel(logging.DEBUG)

if __name__ == "__main__":
    # app.run(debug=True)  # This is the default line that needs to be changed

    # Tell Flask to listen on all interfaces (0.0.0.0) and on port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)
