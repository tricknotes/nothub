FROM node:14.15.3 as node-base
FROM ruby:2.7.2

COPY --from=node-base /usr/local /usr/local
COPY --from=node-base /opt /opt

RUN mkdir /app
WORKDIR /app

# Start the main process.
CMD ["bundle", "exec", "rake", "extension"]
