FROM ruby:3.3.5-bookworm

WORKDIR /spina-app

# Copy Gemfile and Gemfile.lock
COPY . .
RUN bundle install

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
