# Build stage
FROM alpine:3.19 as builder

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    make \
    musl-dev \
    zlib-dev

# Copy source code
WORKDIR /src
COPY . .

# Build the application
RUN make

# Runtime stage
FROM alpine:3.19

# Install runtime dependencies, including gcompat for glibc compatibility
RUN apk add --no-cache \
    gcompat \
    libstdc++ \
    zlib

# Copy the built binary from the builder stage
COPY --from=builder /src/nanoplexer /usr/local/bin/
RUN chmod +x /usr/local/bin/nanoplexer

# Set up working directory
WORKDIR /data

# Create a non-root user
RUN addgroup -S appuser && \
    adduser -S -G appuser appuser

RUN chown appuser:appuser /data

# Switch to non-root user
USER appuser

# Set the entrypoint
ENTRYPOINT ["nanoplexer"]
CMD ["--help"]
