FROM ruby:2.1-onbuild

EXPOSE 4567

WORKDIR /usr/src/app/

CMD ["ruby", "app.rb"]
