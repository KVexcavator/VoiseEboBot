FROM ruby:3.1.0
WORKDIR /code
COPY . /code
RUN bundle  install
CMD ["rake"]
