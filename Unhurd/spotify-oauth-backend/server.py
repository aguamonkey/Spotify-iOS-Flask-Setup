# server.py
from app import app
import logging
app.logger.setLevel(logging.DEBUG)


if __name__ == "__main__":
    app.run(debug=True)

