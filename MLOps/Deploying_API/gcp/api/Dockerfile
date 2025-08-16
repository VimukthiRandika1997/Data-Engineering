# Use an official Python runtime as the base image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app
# Copy requirements first for better Docker layer caching
COPY src/requirements.txt .
# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
# Copy the application code to the container
COPY src/ .
# Expose the port on which the application will run
EXPOSE 8080
# Set the command to run the application when the container starts
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]