FROM ruby:2.1-onbuild

EXPOSE 3000

WORKDIR /usr/src/app/

CMD ["ruby", "app.rb"]
