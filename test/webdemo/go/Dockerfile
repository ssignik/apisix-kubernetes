# Use the official Go image as the base image
FROM golang:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files to the working directory
COPY go.mod .

# Download and cache Go modules
RUN go mod download

# Copy the source code to the working directory
COPY canary-demo.go .

# Build the Go application
RUN go build -o canary-demo .

# Expose port 8080 for the web server
EXPOSE 8080

# Set the command to run the executable when the container starts
CMD ["./canary-demo"]