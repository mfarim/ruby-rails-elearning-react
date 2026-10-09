FROM ruby:3.3-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install bundler
RUN gem install bundler --no-document

# Copy Gemfile and lock
COPY Gemfile Gemfile.lock* ./

# Install dependencies
RUN bundle install --jobs 4 --retry 3

# Copy application source code
COPY . .

# Ensure storage directories exist
RUN mkdir -p storage/uploads tmp/pids log && \
    chmod +x bin/docker-entrypoint

EXPOSE 8000

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
