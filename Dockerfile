FROM mcr.microsoft.com/playwright/python:v1.47.0-jammy

WORKDIR /app

# Install Python requirements as root
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Ensure /app is owned by the HF Space user (UID 1000)
RUN chown -R 1000:1000 /app

# Switch to the pre-existing user 1000 (pwuser)
USER 1000
ENV HOME=/home/pwuser

# Copy the archive and requirements
COPY --chown=1000:1000 requirements.txt app.tar.gz ./

# Extract the actual code dynamically inside the container
RUN tar -xzf app.tar.gz && rm app.tar.gz

# Download Playwright and Camoufox browser binaries as user 1000
ENV PLAYWRIGHT_BROWSERS_PATH=/home/pwuser/.cache/ms-playwright
RUN python -m playwright install chromium
RUN python -m camoufox fetch

# Set up port (Hugging Face Spaces expects 7860)
ENV PORT=7860
EXPOSE 7860

# Start the uvicorn server
CMD ["python3", "-m", "src.main"]
