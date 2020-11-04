FROM ruby:2.7.0

WORKDIR /code

COPY . /code

RUN bundle install

EXPOSE 4567

CMD 
