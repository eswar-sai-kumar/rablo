# Stage 1: Use an official Python runtime as a parent image
FROM python:3.9-slim

# Stage 2: Set the working directory inside the container
WORKDIR /app

# Stage 3: Copy the dependencies file and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 4: Copy the application code into the container
COPY app.py .

# Stage 5: Expose port 80 to the outside world
EXPOSE 80

# Stage 6: Command to run the application
CMD ["python", "app.py"]